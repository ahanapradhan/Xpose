from sentence_transformers import SentenceTransformer, util

model = SentenceTransformer('all-MiniLM-L6-v2')
#model = SentenceTransformer('text-embedding-ada-002')

s1 = "This query provides a high-level summary of sales transactions that were returned for a specific reason, focusing only on those with quantities between 1 and 100 units. It gives five key performance indicators: the total number of return transactions (`bucket1`), the total discounts given on those transactions (`bucket2`), the total profit impact (`bucket3`), the average quantity per return (`bucket4`), and the highest item price involved (`bucket5`). By sorting the results by profit, this analysis helps a business manager quickly identify how returns tied to a particular reason are affecting revenue and profitability, and where to focus efforts to reduce losses or improve return-related processes."
s2 = "This query provides a detailed snapshot of sales performance segmented by quantity ranges, specifically for transactions associated with a particular return reason (`r_reason_sk = 1`). It divides sales into five quantity \"buckets\" — 1–20, 21–40, 41–60, 61–80, and 81–100 units. For each bucket, the logic evaluates how many transactions occurred: if the number of transactions exceeds a predefined threshold for that range, the query returns the **average list price** of items sold in that range; if not, it returns the **average net profit** instead. This helps a business manager understand how sales behave across different volume segments — highlighting whether high-volume sales are generating strong pricing performance or if lower-volume sales are more profitable. It's a valuable way to assess the trade-off between sales volume and profitability, especially in the context of returns."

embeddings = model.encode([s1, s2], convert_to_tensor=True)
cosine_score = util.pytorch_cos_sim(embeddings[0], embeddings[1]).item()

print(f"Cosine Similarity (Sentence-BERT): {cosine_score:.3f}")
