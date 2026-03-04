# Task: Extract Pain Points from Raw Platform Data

## Context
You are processing raw scraped data from a single platform to extract consumer pain points
for the category: {category}. This is Phase 1 of the analysis pipeline -- the output feeds
into the cross-validation step.

## Input
- **Platform**: {platform} (amazon | reddit | youtube | google_maps | tiktok)
- **Raw Data Location**: `data/raw/{platform}/{session_id}/`
- **Category Keywords**: {keywords}
- **Time Range Filter**: {time_range} (e.g., "6months")

## Platform-Specific Extraction Rules

### Amazon
**Data source**: Product listings, customer reviews, Q&A sections

1. **Filter negative reviews**: Select reviews with rating <= 3 stars
2. **Extract complaint themes**: For each negative review, identify the primary complaint:
   - Read the review title and body
   - Classify into one or more themes (see Theme Taxonomy below)
   - Extract the most descriptive sentence as a representative quote
3. **Calculate frequency**: `theme_frequency = count(reviews_mentioning_theme) / count(all_negative_reviews)`
4. **Extract product-level signals**:
   - Products with rating < 3.5 AND review_count > 100: strong negative signal
   - Products with "Amazon's Choice" badge but rating < 4.0: opportunity signal
   - Price clusters: group products by price bracket ($0-25, $25-50, $50-100, $100+)
5. **Capture verified purchase ratio**: Higher weight to verified purchase reviews

**Output per pain point**:
```json
{
  "theme": "canonical_theme_name",
  "frequency_pct": 45.2,
  "sample_size": 847,
  "impact_level": "functional",
  "representative_quotes": [
    {"text": "...", "rating": 2, "verified": true, "date": "2026-01-15", "asin": "B0...", "url": "..."}
  ],
  "price_bracket_correlation": "$25-50 bracket has 2x more complaints about this theme"
}
```

### Reddit
**Data source**: Posts and comments from target subreddits

1. **Filter by relevance**: Only process posts/comments that mention category keywords
2. **Filter by engagement**: Prioritize posts with score >= 10 (upvotes - downvotes)
3. **Sentiment classification**: For each relevant post/comment:
   - NEGATIVE: explicit complaint, frustration, product return mention
   - MIXED: pros and cons discussion, "I like X but hate Y"
   - POSITIVE: recommendation, satisfaction (still extract "I wish" statements)
4. **Extract pain points from negative and mixed posts**:
   - Look for: "I wish", "the problem with", "I returned", "broke after", "waste of money",
     "don't buy", "avoid", "disappointed", "terrible", "worst"
   - Capture full context (2-3 sentences around the complaint)
5. **Weight by community agreement**: Upvotes serve as implicit agreement signals
   - 50+ upvotes on a complaint = high confidence
   - 10-49 upvotes = medium confidence
   - < 10 upvotes = low confidence (still include, but note)

**Output per pain point**:
```json
{
  "theme": "canonical_theme_name",
  "post_count": 12,
  "total_upvotes": 340,
  "avg_upvotes_per_post": 28.3,
  "impact_level": "structural",
  "representative_quotes": [
    {"text": "...", "subreddit": "r/Camping", "score": 45, "date": "2026-02-20", "url": "..."}
  ],
  "sentiment_distribution": {"negative": 8, "mixed": 3, "positive_with_caveat": 1}
}
```

### YouTube
**Data source**: Video subtitle transcripts from review videos

1. **Identify review segments**: Parse subtitles for sections discussing product negatives
2. **Keyword triggers**: Scan for phrases indicating negative opinion:
   - "the biggest problem", "my main complaint", "I don't like", "this is where it falls short",
     "the downside", "unfortunately", "deal breaker", "I would not recommend"
3. **Extract contextual window**: For each trigger, capture 30 seconds of surrounding transcript
4. **Note reviewer credibility signals**:
   - Channel subscriber count
   - Video view count
   - Whether video is marked as sponsored/gifted
   - Reviewer's stated usage duration (e.g., "after 3 months of use")
5. **Weight sponsored content lower**: Sponsored reviews rarely mention true negatives,
   so any negatives mentioned in sponsored content get HIGHER significance

**Output per pain point**:
```json
{
  "theme": "canonical_theme_name",
  "video_count": 2,
  "total_views": 125000,
  "impact_level": "functional",
  "representative_quotes": [
    {"text": "...", "video_title": "...", "channel": "...", "timestamp": "4:32", "sponsored": false, "url": "..."}
  ],
  "reviewer_consensus": "2 of 3 reviewers independently mentioned this issue"
}
```

### TikTok
**Data source**: Trending videos and comments mentioning category products

1. **Filter by engagement**: Only process videos with 10K+ views
2. **Extract from video descriptions and comments**: Look for complaint keywords
3. **Track trending complaint hashtags**: e.g., #fail, #dontwaste, #productfail
4. **Note virality of negative content**: Videos showing product failures that went viral
   indicate high-severity pain points

**Output per pain point**:
```json
{
  "theme": "canonical_theme_name",
  "video_count": 3,
  "total_views": 500000,
  "impact_level": "safety",
  "representative_quotes": [
    {"text": "...", "video_id": "...", "views": 200000, "likes": 15000, "url": "..."}
  ],
  "viral_negative_content": true
}
```

## Theme Taxonomy (Canonical Names)

Use these standardized theme names for consistency across platforms:

| Canonical Theme | Synonyms / Indicators |
|----------------|----------------------|
| `durability_failure` | broke, snapped, cracked, fell apart, wear out, cheap material |
| `weight_portability` | too heavy, hard to carry, bulky, not portable, weighs a ton |
| `size_fit_issues` | too small, too big, doesn't fit, wrong dimensions, misleading size |
| `setup_difficulty` | confusing assembly, hard to set up, instructions unclear, missing parts |
| `price_value` | overpriced, not worth it, cheaper alternatives, waste of money |
| `material_quality` | cheap plastic, flimsy, thin fabric, bad stitching, chemical smell |
| `comfort_ergonomics` | uncomfortable, hurts back, too firm, too soft, sagging |
| `noise_issues` | squeaks, creaks, rattles, loud, noisy |
| `stability_safety` | wobbles, tips over, unsafe, unstable, collapses |
| `weather_resistance` | not waterproof, rusts, fades in sun, mold, moisture damage |
| `shipping_packaging` | arrived damaged, poor packaging, slow shipping, wrong item |
| `customer_service` | no response, bad warranty, refused return, unhelpful support |
| `missing_features` | wish it had, no X included, needs Y, would be better with |
| `battery_power` | dies fast, slow charge, weak motor, not enough power |
| `odor_chemical` | chemical smell, off-gassing, stinks, toxic smell |

## Quality Rules
- Minimum 5 data points per pain point to be included
- Every quote must have a verifiable source URL
- Date must be within the specified time_range filter
- Do not include positive-only feedback in pain point extraction
- Flag any data that appears to be fake reviews (repeated phrasing, bulk posting dates)
