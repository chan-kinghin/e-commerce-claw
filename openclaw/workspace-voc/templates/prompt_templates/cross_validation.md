# Task: Cross-Validate Pain Points Across Data Sources

## Context
You have collected raw data from multiple platforms for the category: {category}.
Your job is to cross-validate the findings to ensure only data-backed, multi-source-confirmed
pain points make it into the final report.

## Input Data Locations
- Amazon data: `data/raw/amazon/{session_id}/`
- Reddit data: `data/raw/reddit/{session_id}/`
- YouTube data: `data/raw/youtube/{session_id}/`
- Google Maps data: `data/raw/google-maps/{session_id}/`

## Cross-Validation Process

### Phase 1: Extract Pain Point Candidates
From each data source, extract all negative signals:

**Amazon** (weight: HIGH - largest sample size):
- Filter reviews with rating <= 3 stars
- Extract complaint keywords and phrases
- Group by theme (durability, size, price, usability, shipping, quality)
- Calculate frequency: (complaints mentioning theme / total negative reviews) * 100

**Reddit** (weight: HIGH - authentic long-form feedback):
- Identify posts/comments expressing dissatisfaction
- Extract specific product complaints with context
- Note upvote counts as signal of community agreement
- Flag posts with 50+ upvotes as high-confidence signals

**YouTube** (weight: MEDIUM - KOL perspective, potential bias):
- From subtitle transcripts, extract segments where reviewer mentions negatives
- Look for phrases: "the problem is", "I wish", "downside", "issue", "broke", "returned"
- Note if multiple reviewers mention the same issue independently
- Discount sponsored content (lower weight if video is marked as sponsored)

**Google Maps** (weight: LOW - supplier-side, not consumer):
- Extract supplier density data (competition indicator)
- Note wholesale price ranges if available
- This data does not contribute to pain points directly but informs market opportunity

### Phase 2: Theme Matching
For each pain point candidate from Phase 1:

1. **Normalize the language**: Map synonyms to canonical themes
   - "broke", "snapped", "cracked", "fell apart" -> "durability_failure"
   - "too heavy", "hard to carry", "weighs a ton" -> "weight_portability"
   - "overpriced", "not worth the money", "cheaper alternatives" -> "price_value"
   - "confusing setup", "took an hour to assemble", "instructions unclear" -> "setup_difficulty"

2. **Count source agreement**: For each canonical theme, count how many independent
   platforms mention it. A platform "mentions" a theme if:
   - Amazon: >= 5% of negative reviews contain the theme
   - Reddit: >= 2 posts with 10+ upvotes mention the theme
   - YouTube: >= 1 reviewer explicitly calls it out as a negative

3. **Score severity**: `severity = frequency_weight * impact_weight * recency_factor`
   - frequency_weight: (mentions / total_negative_signals) * 10
   - impact_weight: 1.0 (cosmetic), 1.5 (functional), 2.0 (safety/structural)
   - recency_factor: 1.0 (last 3 months), 0.8 (3-6 months), 0.5 (6-12 months)

### Phase 3: Contradiction Detection
Check for cross-source contradictions:
- If Amazon reviews say "great durability" (4+ star reviews, 30%+ mention) BUT Reddit
  says "broke after 2 uses" (3+ posts with 20+ upvotes) -> Flag as CONTRADICTION
- Record both sides with evidence
- Do NOT suppress either signal; present both to Lead for human judgment
- Mark contradicted pain points with `"has_contradiction": true` in the report

### Phase 4: Final Ranking
1. Filter: Only keep pain points with `source_count >= 2`
2. Sort by severity_score descending
3. For each pain point, select 2-3 representative quotes with source URLs
4. Generate a design_opportunity suggestion based on the gap identified
5. Cap at top 10 pain points for the final report

## Output Format
Return a JSON array of validated pain points:

```json
[
  {
    "rank": 1,
    "issue": "Canonical pain point title",
    "severity_score": 9.2,
    "frequency": "mentioned in 68% of negative reviews",
    "sources": ["amazon_reviews", "reddit_r/Camping", "youtube_video_1"],
    "source_count": 3,
    "has_contradiction": false,
    "representative_quotes": [
      {
        "text": "Exact quote from source",
        "source": "Platform and location",
        "url": "Direct URL to source"
      }
    ],
    "design_opportunity": "Actionable product improvement suggestion"
  }
]
```

## Quality Checks Before Returning
- [ ] Every pain point has source_count >= 2
- [ ] Every quote has a valid source URL
- [ ] Severity scores are between 0.0 and 10.0
- [ ] No duplicate themes in the final list
- [ ] Contradictions are flagged, not suppressed
- [ ] Design opportunities are specific and actionable (not "make it better")
