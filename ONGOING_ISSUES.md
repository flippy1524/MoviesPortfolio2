# Ongoing Issues

Known bugs and UX problems not yet resolved.

## Trending — scroll flicker and cell recycling

**Status:** Open  
**Area:** Trending tab (`TrendingView`, `LazyVGrid`)

While scrolling the trending grid, content sometimes flickers or disappears briefly. Empty gaps can appear, and previously visible cells may be repositioned to fill the space. Scrolling further usually brings the content back.

**Attempted mitigations (still insufficient):**

- Replaced per-cell `NavigationLink` with `NavigationPath` + tap gesture
- Removed `maxHeight: .infinity` from grid cells
- Moved pagination spinner outside `LazyVGrid`
- Simplified `PosterImageView` layout (removed `GeometryReader`)
- Disabled grid animations on pagination append
