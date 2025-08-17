// TPC-H Q3 (Shipping Priority) — C11 + libpq (PostgreSQL client)
// ----------------------------------------------------------------
// Loads the needed columns from Postgres into memory, then performs the Q3 logic
// in a straightforward procedural style (filters, joins, aggregation, sort, limit).
//
// Build (Linux/macOS):
//   gcc -std=c11 -O2 tpch_q3_procedural.c -o q3 -lpq
//
// Run:
//   ./q3 --conn "postgresql://tpch:tpch@localhost:5432/tpch" \
//        --segment BUILDING --date 1995-03-15 --limit 10
//
// Notes:
//  * Only the columns required for Q3 are fetched.
//  * Dates are stored as int YYYYMMDD for fast comparisons and stable sorting.
//  * Revenue is computed in double; for exact TPC-H compliance use DECIMAL math in SQL or a decimal lib.

#define _POSIX_C_SOURCE 200809L
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <ctype.h>
#include <assert.h>
#include <libpq-fe.h>

// ---------------------------
// Date helpers (YYYYMMDD int)
// ---------------------------
static int parse_date(const char* s) {
    if (!s) { fprintf(stderr, "NULL date\n"); exit(1); }
    size_t n = strlen(s);
    if (n == 10 && s[4] == '-' && s[7] == '-') {
        int y = atoi((char[]){s[0],s[1],s[2],s[3],0});
        int m = atoi((char[]){s[5],s[6],0});
        int d = atoi((char[]){s[8],s[9],0});
        return y*10000 + m*100 + d;
    } else if (n == 8) {
        return atoi(s);
    } else {
        fprintf(stderr, "Bad date format: %s\n", s);
        exit(2);
    }
}

// ---------------------------
// Row types
// ---------------------------
typedef struct { int c_custkey; char* c_mktsegment; } CustomerRow;
typedef struct { int o_orderkey; int o_custkey; int o_orderdate; int o_shippriority; } OrderRow;
typedef struct { int l_orderkey; double l_extendedprice; double l_discount; int l_shipdate; } LineitemRow;

// Qualifying orders after WHERE filters on Customer/Orders
typedef struct { int orderkey; int orderdate; int shippriority; } QualOrder;

// Result rows for output
typedef struct { int orderkey; double revenue; int orderdate; int shippriority; } Q3Row;

// ---------------------------
// Table containers
// ---------------------------
typedef struct { CustomerRow* rows; size_t n; } Customers;
typedef struct { OrderRow* rows; size_t n; } Orders;
typedef struct { LineitemRow* rows; size_t n; } Lineitems;

typedef struct { QualOrder* rows; size_t n; } QualOrders;

typedef struct { Q3Row* rows; size_t n; } Results;

// ---------------------------
// Postgres helpers
// ---------------------------
static void check_status(PGconn* c) {
    if (PQstatus(c) != CONNECTION_OK) {
        fprintf(stderr, "Connection failed: %s\n", PQerrorMessage(c));
        PQfinish(c); exit(1);
    }
}

static void fail_res(PGresult* r, PGconn* c, const char* msg) {
    fprintf(stderr, "%s: %s\n", msg, PQerrorMessage(c));
    if (r) PQclear(r);
    PQfinish(c); exit(1);
}

static void set_datestyle(PGconn* c) {
    PGresult* r = PQexec(c, "SET datestyle TO ISO" );
    if (PQresultStatus(r) != PGRES_COMMAND_OK) fail_res(r, c, "SET datestyle failed");
    PQclear(r);
}

// ---------------------------
// Loaders (fetch only needed cols)
// ---------------------------
static Customers load_customers(PGconn* c) {
    const char* sql = "SELECT c_custkey, c_mktsegment FROM customer";
    PGresult* r = PQexec(c, sql);
    if (PQresultStatus(r) != PGRES_TUPLES_OK) fail_res(r, c, "load_customers failed");
    int n = PQntuples(r);
    Customers T = { .rows = calloc((size_t)n, sizeof(CustomerRow)), .n = (size_t)n };
    for (int i = 0; i < n; ++i) {
        const char* v0 = PQgetvalue(r, i, 0);
        const char* v1 = PQgetvalue(r, i, 1);
        T.rows[i].c_custkey = atoi(v0);
        T.rows[i].c_mktsegment = strdup(v1);
    }
    PQclear(r);
    return T;
}

static Orders load_orders(PGconn* c) {
    const char* sql = "SELECT o_orderkey, o_custkey, o_orderdate, o_shippriority FROM orders";
    PGresult* r = PQexec(c, sql);
    if (PQresultStatus(r) != PGRES_TUPLES_OK) fail_res(r, c, "load_orders failed");
    int n = PQntuples(r);
    Orders T = { .rows = calloc((size_t)n, sizeof(OrderRow)), .n = (size_t)n };
    for (int i = 0; i < n; ++i) {
        T.rows[i].o_orderkey = atoi(PQgetvalue(r, i, 0));
        T.rows[i].o_custkey = atoi(PQgetvalue(r, i, 1));
        T.rows[i].o_orderdate = parse_date(PQgetvalue(r, i, 2));
        T.rows[i].o_shippriority = atoi(PQgetvalue(r, i, 3));
    }
    PQclear(r);
    return T;
}

static Lineitems load_lineitems(PGconn* c) {
    const char* sql = "SELECT l_orderkey, l_extendedprice, l_discount, l_shipdate FROM lineitem";
    PGresult* r = PQexec(c, sql);
    if (PQresultStatus(r) != PGRES_TUPLES_OK) fail_res(r, c, "load_lineitems failed");
    int n = PQntuples(r);
    Lineitems T = { .rows = calloc((size_t)n, sizeof(LineitemRow)), .n = (size_t)n };
    for (int i = 0; i < n; ++i) {
        T.rows[i].l_orderkey = atoi(PQgetvalue(r, i, 0));
        T.rows[i].l_extendedprice = strtod(PQgetvalue(r, i, 1), NULL);
        T.rows[i].l_discount = strtod(PQgetvalue(r, i, 2), NULL);
        T.rows[i].l_shipdate = parse_date(PQgetvalue(r, i, 3));
    }
    PQclear(r);
    return T;
}

// ---------------------------
// Util: sort & search
// ---------------------------
static int cmp_int(const void* a, const void* b) {
    int x = *(const int*)a, y = *(const int*)b; return (x>y) - (x<y);
}

static int cmp_qual_by_orderkey(const void* a, const void* b) {
    const QualOrder* A = (const QualOrder*)a; const QualOrder* B = (const QualOrder*)b;
    return (A->orderkey > B->orderkey) - (A->orderkey < B->orderkey);
}

static int cmp_results(const void* a, const void* b) {
    const Q3Row* A = (const Q3Row*)a; const Q3Row* B = (const Q3Row*)b;
    if (A->revenue < B->revenue) return 1;   // DESC
    if (A->revenue > B->revenue) return -1;
    if (A->orderdate < B->orderdate) return -1; // ASC
    if (A->orderdate > B->orderdate) return 1;
    // tie-breaker for determinism
    return (A->orderkey > B->orderkey) - (A->orderkey < B->orderkey);
}

// binary search for orderkey in sorted QualOrders; returns index or -1
static long find_qual_index(const QualOrders* Q, int orderkey) {
    long lo = 0, hi = (long)Q->n - 1;
    while (lo <= hi) {
        long mid = lo + ((hi - lo) >> 1);
        int ok = Q->rows[mid].orderkey;
        if (ok == orderkey) return mid;
        if (ok < orderkey) lo = mid + 1; else hi = mid - 1;
    }
    return -1;
}

// ---------------------------
// Q3 logic
// ---------------------------
static Results run_q3(const Customers* C, const Orders* O, const Lineitems* L, const char* segment, int cutoff, size_t limit) {
    Results R = { .rows = NULL, .n = 0 };

    // 1) Build the set of customer keys for the given segment
    int* segKeys = malloc(C->n * sizeof(int)); size_t segN = 0;
    for (size_t i = 0; i < C->n; ++i) {
        if (strcmp(C->rows[i].c_mktsegment, segment) == 0) {
            segKeys[segN++] = C->rows[i].c_custkey;
        }
    }
    qsort(segKeys, segN, sizeof(int), cmp_int);

    // 2) Collect qualifying orders: o_custkey in segment & o_orderdate < cutoff
    QualOrders Q = { .rows = malloc(O->n * sizeof(QualOrder)), .n = 0 };
    for (size_t i = 0; i < O->n; ++i) {
        const OrderRow* o = &O->rows[i];
        if (o->o_orderdate >= cutoff) continue;
        // membership test via bsearch
        if (segN == 0) continue;
        void* hit = bsearch(&o->o_custkey, segKeys, segN, sizeof(int), cmp_int);
        if (hit) {
            Q.rows[Q.n++] = (QualOrder){ o->o_orderkey, o->o_orderdate, o->o_shippriority };
        }
    }

    if (Q.n == 0) {
        free(segKeys);
        R.rows = calloc(1, sizeof(Q3Row)); R.n = 0; // empty
        return R;
    }

    // Sort qualifying orders by orderkey for fast lookup
    qsort(Q.rows, Q.n, sizeof(QualOrder), cmp_qual_by_orderkey);

    // 3) Aggregation: for each lineitem with l_shipdate > cutoff, if its order is in Q, accumulate revenue.
    double* revenue = calloc(Q.n, sizeof(double));

    for (size_t i = 0; i < L->n; ++i) {
        const LineitemRow* li = &L->rows[i];
        if (li->l_shipdate <= cutoff) continue;
        long idx = find_qual_index(&Q, li->l_orderkey);
        if (idx >= 0) {
            double rev = li->l_extendedprice * (1.0 - li->l_discount);
            revenue[idx] += rev;
        }
    }

    // 4) Materialize results (only orders with revenue > 0)
    Q3Row* tmp = malloc(Q.n * sizeof(Q3Row)); size_t m = 0;
    for (size_t i = 0; i < Q.n; ++i) {
        if (revenue[i] > 0.0) {
            tmp[m++] = (Q3Row){ Q.rows[i].orderkey, revenue[i], Q.rows[i].orderdate, Q.rows[i].shippriority };
        }
    }

    // 5) Sort: revenue DESC, orderdate ASC; then take limit
    qsort(tmp, m, sizeof(Q3Row), cmp_results);
    if (m > limit) m = limit;

    R.rows = realloc(tmp, m * sizeof(Q3Row));
    R.n = m;

    // cleanup
    free(segKeys);
    free(Q.rows);
    free(revenue);

    return R;
}

// ---------------------------
// CLI parsing
// ---------------------------
static void usage(const char* prog) {
    fprintf(stderr,
        "Usage: %s --conn <conninfo> [--segment <SEG>] [--date <YYYY-MM-DD>] [--limit <N>]\n",
        prog);
}

int main(int argc, char** argv) {
    const char* conninfo = NULL;
    const char* segment = "BUILDING";
    const char* date_str = "1995-03-15";
    size_t limit = 10;

    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--conn") == 0 && i+1 < argc) { conninfo = argv[++i]; }
        else if (strcmp(argv[i], "--segment") == 0 && i+1 < argc) { segment = argv[++i]; }
        else if (strcmp(argv[i], "--date") == 0 && i+1 < argc) { date_str = argv[++i]; }
        else if (strcmp(argv[i], "--limit") == 0 && i+1 < argc) { limit = (size_t)strtoull(argv[++i], NULL, 10); }
        else if (strcmp(argv[i], "--help") == 0 || strcmp(argv[i], "-h") == 0) { usage(argv[0]); return 0; }
        else { fprintf(stderr, "Unknown arg: %s\n", argv[i]); usage(argv[0]); return 2; }
    }

    if (!conninfo) { usage(argv[0]); return 2; }

    int cutoff = parse_date(date_str);

    // Connect
    PGconn* conn = PQconnectdb(conninfo);
    check_status(conn);
    set_datestyle(conn);

    fprintf(stderr, "Loading CUSTOMER...\n");
    Customers C = load_customers(conn);
    fprintf(stderr, "Loaded %zu customers\n", C.n);

    fprintf(stderr, "Loading ORDERS...\n");
    Orders O = load_orders(conn);
    fprintf(stderr, "Loaded %zu orders\n", O.n);

    fprintf(stderr, "Loading LINEITEM...\n");
    Lineitems L = load_lineitems(conn);
    fprintf(stderr, "Loaded %zu lineitems\n", L.n);

    // Done with DB
    PQfinish(conn);

    // Run the query in memory
    Results R = run_q3(&C, &O, &L, segment, cutoff, limit);

    // Output
    printf("l_orderkey\trevenue\to_orderdate\to_shippriority\n");
    for (size_t i = 0; i < R.n; ++i) {
        const Q3Row* r = &R.rows[i];
        int y = r->orderdate/10000; int m = (r->orderdate/100)%100; int d = r->orderdate%100;
        printf("%d\t%.2f\t%04d-%02d-%02d\t%d\n", r->orderkey, r->revenue, y, m, d, r->shippriority);
    }

    // Clean up heap allocations
    for (size_t i = 0; i < C.n; ++i) free(C.rows[i].c_mktsegment);
    free(C.rows);
    free(O.rows);
    free(L.rows);
    free(R.rows);

    return 0;
}
