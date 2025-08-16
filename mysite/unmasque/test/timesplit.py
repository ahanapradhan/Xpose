import csv
import matplotlib.pyplot as plt
import numpy as np
from pathlib import Path

# Configuration
CONFIG = {
    'bar_width': 0.55,
    'x_label': 'Queries',
    'y_label': 'Query Extraction Time (s)',
    'figure_size': (10, 5),
    'font_config': {
        'font.family': 'JetBrainsMono NF',
        'font.size': 25,
        'axes.titlesize': 23,
        'axes.labelsize': 23,
        'xtick.labelsize': 25,
        'ytick.labelsize': 25,
        'legend.fontsize': 17,
    }
}

# Color scheme
COLORS = {
    'HM': '#5566ee',
    'GM': '#aa22aa',
    'RM': '#ff6666',
    'PE_PS': '#000000',
    'OTHER': '#21e767'
}


class PerformanceAnalyzer:
    def __init__(self):
        # Initialize data containers
        self.metrics = {
            'backup': [],
            'from_clause': [],
            'minimization': [],
            'equi_join': [],
            'group_by': [],
            'predicate_extraction': [],
            'projection': [],
            'aggregation': [],
            'predicate_separation': [],
            'order_by': [],
            'limit': []
        }
        self.queries = []
        self.totals = []

        # Hardcoded benchmark data (from your original code)
        self.halving_times = np.array([2.87, 2.98, 12.95, 9.33, 2.26, 1.74, 2.68,
                                       13.65, 2.90, 1.53, 2.77, 0.53, 0.51, 3.23, 1.60, 1.92])
        self.gm_times = np.array([3.32, 3.89, 11.33, 11.98, 2.17, 1.93, 3.47,
                                  13.78, 3.34, 2.11, 3.58, 0.33, 26.32, 28.76, 4.01, 29.29])

    def load_data(self, data_dir='data', num_queries=16):
        """Load CSV data files and populate metrics."""
        data_path = Path(data_dir)

        for i in range(1, num_queries + 1):
            csv_filename = data_path / f'H{i}.csv'
            print(f"Processing: {csv_filename}")

            self.queries.append(f'H{i}')
            total = 0

            try:
                with open(csv_filename, 'r') as csv_file:
                    csv_reader = csv.reader(csv_file)
                    next(csv_reader)  # Skip header - more readable than __next__()

                    for row in csv_reader:
                        if len(row) < 2:
                            continue

                        try:
                            value = float(row[1])
                            total += value
                            self._categorize_metric(row[0], value)
                        except (ValueError, IndexError) as e:
                            print(f"Warning: Skipping invalid row {row}: {e}")

            except FileNotFoundError:
                print(f"Warning: File {csv_filename} not found")
                # Add zeros for missing data to maintain array consistency
                for metric_list in self.metrics.values():
                    metric_list.append(0.0)

            print(f'Total time for Q{i}: {total:.2f} seconds\n')
            self.totals.append(total)

    def _categorize_metric(self, metric_name, value):
        """Categorize metrics using if-elif instead of match-case for Python 3.9."""
        if metric_name == 'RestoreDB':
            self.metrics['backup'].append(value)
        elif metric_name == 'FromClause':
            self.metrics['from_clause'].append(value)
        elif metric_name == 'BruteforceMinimization':
            self.metrics['minimization'].append(value)
        elif metric_name == 'WhereClause':
            self.metrics['equi_join'].append(value)
        elif metric_name == 'GroupBY':
            self.metrics['group_by'].append(value)
        elif metric_name == 'PredicateExtraction':
            self.metrics['predicate_extraction'].append(value)
        elif metric_name == 'Projection':
            self.metrics['projection'].append(value)
        elif metric_name == 'Aggregation':
            self.metrics['aggregation'].append(value)
        elif metric_name == 'PredicateSeparation':
            self.metrics['predicate_separation'].append(value)
        elif metric_name == 'Orderby':
            self.metrics['order_by'].append(value)
        elif metric_name == 'Limit':
            self.metrics['limit'].append(value)
        else:
            print(f"Warning: Unknown metric '{metric_name}' with value {value}")

    def convert_to_arrays(self):
        """Convert all metric lists to numpy arrays."""
        for key in self.metrics:
            self.metrics[key] = np.array(self.metrics[key])

    def create_visualization(self, save_path='performance_chart.eps', show_plot=True):
        """Create the performance visualization chart.

        Args:
            save_path (str): Path to save the EPS file
            show_plot (bool): Whether to display the plot
        """
        # Set up matplotlib with configuration
        plt.rcParams.update(CONFIG['font_config'])

        # Calculate derived metrics
        rm_times = self.metrics['minimization'] - self.gm_times
        pe_ps_combined = self.metrics['predicate_extraction'] + self.metrics['predicate_separation']
        others = (self.metrics['from_clause'] + self.metrics['equi_join'] +
                  self.metrics['group_by'] + self.metrics['projection'] +
                  self.metrics['aggregation'] + self.metrics['order_by'] +
                  self.metrics['limit'])

        # Create the plot
        fig, ax = plt.subplots(figsize=CONFIG['figure_size'])
        ax.set_xlabel(CONFIG['x_label'])
        ax.set_ylabel(CONFIG['y_label'])
        ax.set_axisbelow(True)

        n = len(self.queries)
        r1 = np.arange(n)

        # Create stacked bars
        ax.bar(r1, self.halving_times, color=COLORS['HM'],
               width=CONFIG['bar_width'], label='HM')
        ax.bar(r1, self.gm_times, color=COLORS['GM'],
               width=CONFIG['bar_width'], label='GM', bottom=self.halving_times)
        ax.bar(r1, rm_times, color=COLORS['RM'],
               width=CONFIG['bar_width'], label='RM',
               bottom=self.halving_times + self.gm_times)
        ax.bar(r1, pe_ps_combined, color=COLORS['PE_PS'],
               width=CONFIG['bar_width'], label='PE + PS',
               bottom=self.halving_times + self.metrics['minimization'])
        ax.bar(r1, others, color=COLORS['OTHER'],
               width=CONFIG['bar_width'], label='OTHER',
               bottom=self.halving_times + self.metrics['minimization'] + pe_ps_combined)

        # Configure x-axis
        ax.set_xticks(range(n), self.queries, rotation=90)

        # Position legend
        box = ax.get_position()
        ax.set_position((box.x0, box.y0 + box.height * 0.1,
                         box.width, box.height * 0.85))

        handles, labels = ax.get_legend_handles_labels()
        ax.legend(handles, labels, loc='upper center',
                  bbox_to_anchor=(0.5, 1.2), ncol=5, frameon=False)

        # Save as EPS file
        try:
            plt.savefig(save_path, format='eps', bbox_inches='tight',
                        dpi=300, facecolor='white')
            print(f"Plot saved as: {save_path}")
        except Exception as e:
            print(f"Warning: Could not save EPS file: {e}")

        # Display the plot if requested
        if show_plot:
            plt.show()

        plt.close()  # Clean up to prevent memory leaks

    def print_summary(self):
        """Print summary statistics."""
        print("\nSummary Statistics:")
        print("=" * 40)
        for i, total in enumerate(self.totals, 1):
            print(f"H{i}: {total:.2f}s")
        print(f"\nAverage total time: {np.mean(self.totals):.2f}s")
        print(f"Max total time: {np.max(self.totals):.2f}s")
        print(f"Min total time: {np.min(self.totals):.2f}s")


def main():
    """Main execution function."""
    analyzer = PerformanceAnalyzer()

    # Load and process data
    analyzer.load_data()
    analyzer.convert_to_arrays()

    # Display results
    analyzer.print_summary()

    # Create and save visualization
    # You can customize the filename and choose whether to show the plot
    analyzer.create_visualization(
        save_path='PerfHaving1G.eps',  # Custom filename
        show_plot=True  # Set to False if you only want to save without displaying
    )


if __name__ == "__main__":
    main()