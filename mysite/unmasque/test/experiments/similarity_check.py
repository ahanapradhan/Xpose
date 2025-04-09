from sentence_transformers import SentenceTransformer, util

model = SentenceTransformer('all-MiniLM-L6-v2')
#model = SentenceTransformer('text-embedding-ada-002')

s1 = "This report gives a complete financial snapshot of store, catalog, and web sales over a 15-day period starting August 22, 2002. For each channel, it combines both sales and returns data to show total revenue (sales), total amount returned (returns), and true profit. Profit is calculated by taking the net profit from sales and subtracting losses caused by returns. The results are grouped by unique identifiers (like store ID, catalog page ID, or website ID), with each entry clearly labeled by its channel. This view helps business managers easily compare performance across channels, identify where the most returns or losses are happening, and make better-informed decisions to boost profitability and reduce return-related losses."
s2 = "This report shows how each sales channel—catalog, store, and web—performed over a two-week period from August 22 to September 5, 2002. For every catalog page, physical store, and website, it adds up the total sales revenue, the amount of money lost due to customer returns, and the overall profit. Profit is calculated by taking the income from sales and subtracting the losses from any returns. The result is a clear, channel-by-channel breakdown that helps you see where revenue is coming from, how much is being lost to returns, and which areas are most profitable. This helps managers identify strong performers, spot problem areas, and make more informed decisions about sales strategy and resource allocation."
embeddings = model.encode([s1, s2], convert_to_tensor=True)
cosine_score = util.pytorch_cos_sim(embeddings[0], embeddings[1]).item()

print(f"Cosine Similarity (Sentence-BERT): {cosine_score:.3f}")
