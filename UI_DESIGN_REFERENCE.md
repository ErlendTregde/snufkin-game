# 🎨 UI Design Reference - Fishing System

## 📖 Fishing Journal Layout

```
┌────────────────────────────────────────────────────────────────┐
│                     🐟 FISHING JOURNAL 🐟                      │
│                                                                │
│  Collection: 7/12                               [Close ✕]     │
│  ──────────────────────────────────────────────────────────  │
│                                                                │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐         │
│  │   🐟    │  │   🐟    │  │   🐟    │  │    ?    │         │
│  │         │  │         │  │         │  │         │         │
│  │ Silver  │  │Rainbow  │  │ Moon    │  │   ???   │         │
│  │ Perch   │  │ Trout   │  │ Fish    │  │         │         │
│  │         │  │         │  │         │  │         │         │
│  │ Common  │  │Uncommon │  │  Rare   │  │Undiscov.│         │
│  │Caught:3 │  │Caught:1 │  │Caught:1 │  │         │         │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘         │
│                                                                │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐         │
│  │   🐟    │  │   🐟    │  │    ?    │  │    ?    │         │
│  │         │  │         │  │         │  │         │         │
│  │ Creek   │  │ Golden  │  │   ???   │  │   ???   │         │
│  │ Minnow  │  │  Carp   │  │         │  │         │         │
│  │         │  │         │  │         │  │         │         │
│  │ Common  │  │Uncommon │  │Undiscov.│  │Undiscov.│         │
│  │Caught:5 │  │Caught:2 │  │         │  │         │         │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘         │
│                                                                │
│  [... more fish ...]                                           │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

### Fish Detail View (Popup when clicking a fish)

```
        ┌──────────────────────────────────┐
        │                                  │
        │       🐟 Rainbow Trout           │
        │       ─────────────────          │
        │                                  │
        │  Rarity: Uncommon                │
        │                                  │
        │  "Colors shimmer beneath the     │
        │   surface like a quiet promise.  │
        │   Moominmamma would love this."  │
        │                                  │
        │  Total Caught: 3                 │
        │  First Caught: 2/7/2026          │
        │                                  │
        │  "Prefers flowing water..."      │
        │                                  │
        │          [Back]                  │
        │                                  │
        └──────────────────────────────────┘
```

**Colors:**
- Background: Cream (#F5E6D3)
- Border: Warm brown (#8B735C)
- Common fish: Gray background
- Uncommon: Sage green tint
- Rare: Dusty blue tint
- Legendary: Gold/amber tint
- Undiscovered: Dark gray with question mark

---

## 🎁 Fish Delivery UI Layout

```
┌────────────────────────────────────────────────────────────┐
│                Gift a Fish                    [Close ✕]    │
│  ─────────────────────────────────────────────────────     │
│                                                            │
│  To: Moominmamma                                           │
│                                                            │
│  ┌────────────────────────────────────────────────────┐   │
│  │  🐟  Silver Perch                        [Gift]    │   │
│  │      Common                                        │   │
│  │      Available: 2                                  │   │
│  ├────────────────────────────────────────────────────┤   │
│  │  🐟  Rainbow Trout                       [Gift]    │   │
│  │      Uncommon                                      │   │
│  │      Available: 1                                  │   │
│  ├────────────────────────────────────────────────────┤   │
│  │  🐟  Moon Fish                           [Gift]    │   │
│  │      Rare                                          │   │
│  │      Available: 1                                  │   │
│  └────────────────────────────────────────────────────┘   │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

**After gifting, popup shows:**
```
        ┌─────────────────────────────┐
        │   💬 Moominmamma says:      │
        │                             │
        │  "Oh, what a lovely fish!   │
        │   This will make a          │
        │   wonderful soup!"          │
        │                             │
        └─────────────────────────────┘
```

**When inventory is empty:**
```
┌────────────────────────────────────────────────────────────┐
│                Gift a Fish                    [Close ✕]    │
│  ─────────────────────────────────────────────────────     │
│                                                            │
│  To: Moominmamma                                           │
│                                                            │
│                                                            │
│               🎣                                           │
│                                                            │
│         You have no fish to gift.                          │
│         Go fishing first!                                  │
│                                                            │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

---

## 🏆 Achievement Notification

```
┌────────────────────────────────────────────────┐
│  📚  Collection Starter                        │
│                                                │
│      Discover 5 different species              │
│                                                │
└────────────────────────────────────────────────┘
```

**Animation:**
1. Slides down from top of screen (0.5s)
2. Stays visible for 4 seconds
3. Fades out and slides back up (0.5s)
4. Position: Top-center (50px from top when visible)

**Colors:**
- Background: Parchment with gold accent border
- Icon: Large emoji (48px)
- Title: Bold, warm brown (18px)
- Description: Smaller, gray (14px)

**Different achievement examples:**
```
┌────────────────────────────────────────────────┐
│  🎣  First Catch                               │
│      Catch your very first fish                │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│  ✨  Tale of Wonder                            │
│      Catch all legendary fish                  │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│  🌙  Moonlight Fisher                          │
│      Catch 5 fish during nighttime             │
└────────────────────────────────────────────────┘
```

---

## 🎮 In-Game HUD Elements

### During Fishing - Catch Indicator
```
┌─────────────────┐
│  🎣 Cast Hook   │   ← Top-left corner
│  [Space]        │
└─────────────────┘

When fish bites:
┌─────────────────┐
│  ⚡ Fish On!    │   ← Flashing
│  Press [Enter]  │
└─────────────────┘
```

### New Fish Alert (On successful catch)
```
        ┌──────────────────────────┐
        │  ✨ Rare Catch! ✨       │
        │                          │
        │  Moon Fish discovered!   │
        │                          │
        └──────────────────────────┘
        
        + Shimmer particle effect
        + Gentle chime sound
```

### Rarity Visual Feedback
- **Common**: No special effect
- **Uncommon**: Green shimmer particles
- **Rare**: Blue shimmer particles + "✨ Rare Catch!"
- **Legendary**: Gold shimmer particles + "⭐ LEGENDARY! ⭐"

---

## 🎨 Button Styles

### Primary Button (Gift, Close, etc.)
```
┌──────────┐
│   Gift   │  ← Sage green background
└──────────┘   Rounded corners (6px)
               Hover: Slightly lighter
               Press: Slightly darker
```

### Secondary Button (Back, Cancel)
```
┌──────────┐
│   Back   │  ← Cream background
└──────────┘   Warm brown border
               Same rounded corners
```

### Icon Button (Close X)
```
┌───┐
│ ✕ │  ← Transparent background
└───┘   Warm brown color
        Hover: Dusty blue
        Size: 32x32px
```

---

## 📝 Typography

### Headers
- **Font**: Default (or custom Moomin-style font)
- **Size**: 24-32px
- **Color**: Warm brown (#4A4A3A)
- **Style**: Slightly bold

### Body Text
- **Font**: Default
- **Size**: 14-16px
- **Color**: Warm gray (#666666)
- **Style**: Regular

### Labels
- **Font**: Default
- **Size**: 12px
- **Color**: Medium gray (#888888)
- **Style**: Regular or italic for hints

### Rarity Labels
- **Common**: Gray (#999999)
- **Uncommon**: Green (#66B366)
- **Rare**: Blue (#6680E6)
- **Legendary**: Gold (#D9A521)

---

## 🎴 Card Layouts

### Fish Card (Journal)
```
┌─────────────┐
│             │  ← Fish icon or sprite
│     🐟      │     (130x80px area)
│             │
├─────────────┤
│ Rainbow     │  ← Name (center aligned)
│ Trout       │
├─────────────┤
│ Uncommon    │  ← Rarity (colored)
├─────────────┤
│ Caught: 3   │  ← Stats (gray)
└─────────────┘

Overall card: 150x180px
Border: 2px warm brown
Background: Cream
Hover: Subtle shadow + scale 1.05
```

### Fish List Item (Delivery)
```
┌──────────────────────────────────────┐
│ 🐟  Silver Perch          [Gift]    │
│     Common                           │
│     Available: 2                     │
└──────────────────────────────────────┘

Height: 80px
Horizontal layout
Left: Icon (32px)
Center: Fish name + info (stacked)
Right: Gift button (80x40px)
```

---

## 🌟 Special Effects

### Shimmer Particles (Rare Catch)
```
    ✨
  ✨  ✨
    ✨    ← Burst pattern
  ✨  ✨   Fades upward
    ✨     Gold/blue/green
```

**Properties:**
- Count: 20-40 (based on rarity)
- Lifetime: 1.5-2.0 seconds
- Spread: 360 degrees
- Gravity: Negative (float upward)
- Colors: Rarity-based

### Water Ripples (Fish Bite)
```
    ○
   ○ ○
  ○   ○   ← Expanding circles
 ○     ○   White + transparency
○       ○  3 sizes: small, medium, large
```

**Animation:**
- Appears when fish approaches hook
- Expands from small to large
- Fades as it expands
- Duration: 0.8 seconds

---

## 📐 Layout Measurements

### Fishing Journal
- **Window Size**: 1200x800px (centered)
- **Margin**: 40px all sides
- **Grid Columns**: 4
- **Grid Spacing**: 15px
- **Card Size**: 150x180px

### Fish Delivery UI
- **Window Size**: 800x600px (centered)
- **Margin**: 30px all sides
- **List Item Height**: 80px
- **List Spacing**: 10px

### Achievement Popup
- **Size**: 400x120px
- **Position**: Top-center
- **Margin from Top**: 50px (when visible)
- **Padding**: 15px all sides

---

## 🎨 Asset Checklist

### UI Textures
- [ ] Paper texture (tileable, 256x256px)
- [ ] Leather texture (book cover, 512x512px)
- [ ] Button normal state
- [ ] Button hover state
- [ ] Button pressed state
- [ ] Panel border decoration (corner pieces)

### Icons
- [ ] Fish icon (generic, 64x64px)
- [ ] Achievement badges (9 types, pressed flowers)
- [ ] Gift basket (64x64px)
- [ ] Sparkle/star (16x16px, 3 frames)
- [ ] Ripple circle (32, 64, 96px)

### Fish Sprites
- [ ] 12 unique fish (see species list)
- [ ] All facing right
- [ ] Transparent background
- [ ] Size: 64-128px wide

---

## 🎬 UI Animations

### Journal Opening
1. Fade in overlay (0.4s)
2. Book scales from 0.92 to 1.0 (0.6s, elastic ease)
3. Pages flip (optional, 0.3s)

### Fish Card Hover
- Scale: 1.0 → 1.05
- Add shadow (soft, 4px blur)
- Slight rotation (2 degrees)
- Duration: 0.2s

### Achievement Popup
1. **In**: Slide down + fade in (0.5s)
2. **Stay**: 4 seconds
3. **Out**: Slide up + fade out (0.5s)

### Fish Delivery Success
1. Fish item fades out (0.3s)
2. Brief flash/sparkle at NPC (0.2s)
3. Speech bubble appears (0.4s)
4. List refreshes (instant)

---

## 🖼️ Visual Hierarchy

### Importance Order:
1. **Fish Display** (largest, center focus)
2. **Rarity Indicator** (color-coded, prominent)
3. **Collection Progress** (top bar, medium size)
4. **Stats/Details** (smaller, secondary)
5. **Buttons** (functional, not dominating)

### Color Weight:
- **Most Color**: Rarity indicators, buttons
- **Medium Color**: Icons, accents
- **Least Color**: Background, text

---

## 📱 Responsive Considerations

If supporting different resolutions:
- Scale UI proportionally
- Maintain aspect ratios for cards
- Ensure text remains readable (minimum 12px)
- Keep buttons at least 40x40px for touch
- Adjust grid columns for smaller screens (4 → 3 → 2)

---

**This reference provides all visual specs needed to create the UI scenes in Godot!**

Use these layouts as templates when building:
- Control nodes for containers
- Labels for text
- Buttons for interactions
- Panels for backgrounds
- GridContainer for fish cards
- VBoxContainer for lists
