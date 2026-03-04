# Camera Notation Reference

Camera codes used in storyboard `camera` fields. Combinations are expressed with `+` (e.g., `BM+SPI` means breathing movement while slowly pushing in).

## Notation Table

| Code   | Movement           | Description                                       | Typical Usage Window |
|--------|--------------------|---------------------------------------------------|----------------------|
| `BM`   | Breathing Movement | Handheld sway, 2-3 degree oscillation. Simulates someone holding the camera naturally. | Seconds 0-2 (hook) |
| `SPI`  | Slow Push In       | Gradual zoom toward subject. Creates intimacy and draws attention to detail. | Seconds 2-5 (problem reveal) |
| `CU`   | Close-Up           | Tight framing on product detail. Fills 60-80% of frame with subject. | Seconds 5-10 (product demo) |
| `RF`   | Rack Focus         | Shift focus from background to product (or vice versa). Creates depth and directs attention. | Seconds 5-10 (product demo) |
| `PB`   | Pull Back          | Widen from detail to full product in context. Reveals environment and scale. | Seconds 10-15 (scenario/CTA) |
| `TILT` | Tilt               | Vertical camera rotation to reveal feature. Scans product top-to-bottom or bottom-to-top. | Seconds 2-5 (problem reveal) |
| `PAN`  | Pan                | Horizontal sweep across product or scene. Covers wide subjects or comparisons. | Seconds 5-10 (product demo) |
| `FF`   | Freeze Frame       | Hold final frame for CTA text overlay. No camera movement, static composition. | Seconds 12.5-15 (CTA) |

## Combination Rules

- Use `+` to combine movements: `BM+SPI` = breathing movement with slow push in
- Maximum 2 movements per grid (e.g., `CU+RF` is valid, `BM+SPI+CU` is too complex)
- `BM` can combine with any other movement (adds natural shake)
- `FF` should never combine with other movements (freeze means no motion)
- `CU` and `PB` are mutually exclusive (can't zoom in and out simultaneously)

## Movement-to-Seedance Prompt Mapping

When generating video with Seedance, camera codes translate to motion descriptions:

| Code   | Seedance Motion Prompt Addition |
|--------|--------------------------------|
| `BM`   | "handheld camera with subtle natural shake, slight sway" |
| `SPI`  | "camera slowly pushes in toward the subject" |
| `CU`   | "extreme close-up shot, tight framing on detail" |
| `RF`   | "focus shifts from background to foreground subject" |
| `PB`   | "camera pulls back to reveal full scene" |
| `TILT` | "camera tilts vertically to scan the subject" |
| `PAN`  | "camera pans horizontally across the scene" |
| `FF`   | "static shot, no camera movement, freeze frame" |
