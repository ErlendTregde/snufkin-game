# 🎣 Enhanced Fishing System - Setup Guide

## ✅ What Has Been Implemented

All the core backend systems and scripts are complete:

### Core Systems
- ✅ Fish database with 12 unique species (4 rarity tiers)
- ✅ FishingData autoload singleton (save/load, collection tracking)
- ✅ Achievement system (9 achievements with auto-tracking)
- ✅ Rarity-based fish spawning system
- ✅ Collection tracking and inventory management
- ✅ Fish delivery system for NPCs
- ✅ Particle effects for rare catches
- ✅ Journal UI script (Moomin-themed)
- ✅ Achievement notification system
- ✅ NPC integration for fish gifts

### Updated Files
- `scripts/hook.gd` - Integrated collection tracking
- `scripts/fish.gd` - Added fish data management
- `scripts/fish_spawner.gd` - Rarity-based spawning
- `scripts/npc.gd` - Fish delivery integration
- `project.godot` - Added autoloads

### New Files Created
- `data/fish_database.json` - 12 fish species definitions
- `scripts/fishing_data.gd` - Collection & achievement manager
- `scripts/fishing_journal.gd` - Journal UI script
- `scripts/fish_delivery_ui.gd` - NPC gift system
- `scripts/achievement_notification.gd` - Popup notifications
- `scripts/catch_particles.gd` - Rare catch effects
- `scripts/journal_button.gd` - Menu integration
- `scripts/journal_manager.gd` - Global journal access

---

## 🎨 Next Steps: Creating UI in Godot Editor

### Step 1: Create Fishing Journal Scene

**File: `scenes/fishing_journal.tscn`**

1. Create new scene with **Control** root node
2. Set anchors: Full Rect (covers entire screen)
3. Add background overlay (semi-transparent Panel)

**Node Structure:**
```
Control (fishing_journal)
├── Panel (main container)
│   ├── MarginContainer (padding: 40px all sides)
│   │   └── VBoxContainer
│   │       ├── HBoxContainer (TopBar)
│   │       │   ├── Label (ProgressLabel) - "Collection: X/12"
│   │       │   ├── Control (spacer, expand horizontal)
│   │       │   └── Button (CloseButton) - "✕"
│   │       └── ScrollContainer (expand vertical)
│   │           └── GridContainer (FishGrid) - 4 columns
│   └── DetailPanel (hidden initially)
│       └── MarginContainer (padding: 30px)
│           └── VBoxContainer
│               ├── Label (FishName) - Large, bold
│               ├── Label (RarityLabel) - Colored by rarity
│               ├── Label (Description) - Wrapped text
│               ├── Label (StatsLabel) - Catch count, date
│               ├── Label (HintLabel) - Italic quote style
│               └── Button (CloseDetailButton) - "Back"
```

**Styling:**
- Panel: Cream background (#F5E6D3), brown border (#8B735C), rounded corners (12px)
- FishGrid: Spacing 15px, center alignment
- DetailPanel: Position at center, size 700x500, same styling as main panel

**Attach Script:** `res://scripts/fishing_journal.gd`

---

### Step 2: Create Fish Delivery UI Scene

**File: `scenes/fish_delivery_ui.tscn`**

1. Create new scene with **Control** root node
2. Set to cover screen (Full Rect preset)

**Node Structure:**
```
Control (fish_delivery_ui)
└── Panel (centered, 800x600)
    └── MarginContainer (padding: 30px)
        └── VBoxContainer
            ├── HBoxContainer (TopBar)
            │   ├── Label (TitleLabel) - "Gift a Fish"
            │   ├── Control (spacer)
            │   └── Button (CloseButton)
            ├── Label (NPCLabel) - "To: [NPC Name]"
            ├── ScrollContainer (expand vertical)
            │   └── VBoxContainer (FishList) - spacing 10px
            └── Label (EmptyLabel) - "No fish available" (hidden when inventory has fish)
```

**Styling:**
- Panel: Same Moomin theme (cream/sage green)
- TitleLabel: Size 24, sage green color
- NPCLabel: Size 18, warm brown

**Attach Script:** `res://scripts/fish_delivery_ui.gd`

---

### Step 3: Create Achievement Notification

**File: `scenes/achievement_notification.tscn`**

1. Create new scene with **Control** root node
2. Set as **CanvasLayer** (always on top)
3. Position at top-center of screen

**Node Structure:**
```
Control (achievement_notification)
└── Panel (400x120, top-center position)
    └── MarginContainer (padding: 15px)
        └── HBoxContainer (spacing: 15px)
            ├── Label (IconLabel) - Large emoji (48px)
            └── VBoxContainer
                ├── Label (TitleLabel) - Bold, 18px
                └── Label (DescLabel) - 14px, wrapped
```

**Styling:**
- Panel: Parchment background, warm brown border
- Animation: Slides down from top, fades in
- Auto-hides after 4 seconds

**Attach Script:** `res://scripts/achievement_notification.gd`

---

### Step 4: Add Journal Button to Main Menu

**Edit: `scenes/main_menu.tscn`**

1. Find the VBoxContainer with menu buttons
2. Add new Button node
3. Set text: "Fishing Journal" or "📖 Collection"
4. Style to match existing buttons
5. Attach script: `res://scripts/journal_button.gd`

**Position:** Between "Play" and "Settings" (or wherever fits best)

---

### Step 5: Add Catch Particles to Fishing Scene

**Edit: `scenes/fishing_scene.tscn`**

The catch particles are created dynamically by the hook script, but you can create a template:

1. Add **CPUParticles2D** node to fishing scene (inactive)
2. Name it "CatchParticleTemplate"
3. Set properties:
   - Emitting: false
   - One Shot: true
   - Amount: 25
   - Lifetime: 1.5
   - Emission Shape: Sphere (radius 50)
   - Direction: (0, -1)
   - Spread: 360
   - Gravity: (0, -50)
   - Initial Velocity: 50-100

*(Optional - the system creates these dynamically)*

---

## 🎮 Testing the System

### In Godot Editor:
1. **Press F5** to run the game
2. Navigate to fishing scene
3. Catch a fish - watch console for spawn messages
4. Console should show: "🎣 Spawned: [Fish Name] (rarity)"
5. When caught: "🎣 New species discovered!" or "✨ Rare catch!"

### Testing Journal:
1. Press **Backspace** key (temporary) to open journal
2. Should see collection grid with discovered fish
3. Click on a fish to see details
4. Check progress counter updates

### Testing Achievements:
1. Catch first fish → "First Catch" unlocks
2. Catch 5 species → "Collection Starter" unlocks
3. Watch for popup notification at top of screen

### Testing Fish Delivery:
1. Catch some fish (they go to inventory)
2. Go to Moomin Mama NPC
3. Press **F** key near her
4. Gift menu should open showing your fish
5. Click "Gift" to deliver
6. Check console for NPC reaction dialogue

---

## 🐟 Fish Database Overview

### Common Fish (40% spawn rate)
- **Silver Perch**: Peaceful, common in all waters
- **Creek Minnow**: Tiny, darting, fast swimmers
- **Pond Roach**: Everyday companion, sleeps in reeds

### Uncommon Fish (15% spawn rate)
- **Rainbow Trout**: Colorful, prefers flowing water
- **Golden Carp**: Wise, patient, seeks deep water
- **Sunset Bass**: Orange scales, active at dusk

### Rare Fish (7% spawn rate)
- **Moon Fish**: Luminous, appears under full moon
- **Story Fish**: Shimmering scales with tales
- **Northern Pike**: Fierce fighter, lurks in shadows

### Legendary Fish (1% spawn rate)
- **Wanderer's Salmon**: Returns home like Snufkin
- **Hattifattener Eel**: Electric, glows in deep water
- **Valley Guardian**: Ancient protector, truly blessed catch

---

## 🎨 Assets Needed (For Artist)

### Fish Sprites (Priority: High)
Create 12 fish sprites, all facing **right**:
- Small fish (minnow, perch): 64x32px
- Medium fish (trout, bass, carp): 96x48px
- Large fish (pike, salmon, eel): 128x64px
- Style: Moomin aesthetic (soft colors, gentle lines)
- Format: PNG with transparency

**Color Guides:**
- Commons: Grays, silvers, browns
- Uncommon: Golds, oranges, light blues
- Rare: Purples, deep blues, vibrant colors
- Legendary: Ethereal glows, special effects

### UI Elements (Priority: High)
1. **Journal book cover** (512x512px)
   - Weathered leather texture
   - Embossed fish symbol
   - Warm brown/tan colors

2. **Page texture** (tileable 256x256px)
   - Cream parchment paper
   - Subtle stains/aging
   - Gentle texture

3. **Pressed flower badges** (9 achievements, 64x64px each)
   - Maple leaf (autumn)
   - Daisy (spring)
   - Four-leaf clover
   - Snowflake
   - Feather
   - Acorn
   - Seashell
   - Mushroom
   - Star flower

4. **Fish silhouettes** (12 matching sprites)
   - Black filled versions of fish sprites
   - For undiscovered species display
   - 50% opacity

### Effects (Priority: Medium)
1. **Shimmer particles** (16x16px, 3 frames)
   - Small sparkle/star shape
   - Gold: #FFD700
   - Blue: #4169E1
   - Green: #90EE90
   - Semi-transparent

2. **Ripple circles** (3 sizes: 32, 64, 96px)
   - Concentric water ripples
   - White with alpha fade
   - For fish bite indicator

3. **Gift basket icon** (64x64px)
   - Woven basket
   - Ribbon or bow
   - Warm, inviting colors

---

## 🎯 NPC Fish Preferences

### Moominmamma
- **Loves**: Common fish (for cooking soup)
- **Favorites**: Silver Perch, Pond Roach
- **Reaction**: Warm, motherly, grateful
- **Rewards**: Recipes, cooking tips, warm stories

### Moomintroll
- **Loves**: Rare, colorful fish
- **Favorites**: Rainbow Trout, Moon Fish, Story Fish
- **Reaction**: Excited, adventurous, wants to tell Snorkmaiden
- **Rewards**: Adventure stories, friendship moments

### Little My
- **Loves**: Fierce, fighting fish
- **Favorites**: Northern Pike, Hattifattener Eel
- **Reaction**: Impressed, respects strength
- **Rewards**: Chaotic energy, challenges, respect

### Snorkmaiden
- **Loves**: Beautiful, elegant fish
- **Favorites**: Rainbow Trout, Golden Carp, Moon Fish
- **Reaction**: Delighted, aesthetic appreciation
- **Rewards**: Compliments, affection, decorative ideas

---

## 🎹 Controls

### Fishing
- **Space**: Cast/Reel hook
- **Arrow Keys**: Move hook
- **Enter**: Reel in fish

### Collection
- **Backspace** (temporary): Open journal
  - *Add custom keybind in project settings: "open_journal"*
- **E**: Interact with NPC (dialogue)
- **F**: Gift fish (when near NPC)

### UI
- **ESC**: Close journal/delivery UI
- **Click**: Interact with buttons/fish slots

---

## 📊 Achievement Unlock Conditions

1. **First Catch** ✅ Automatic on first fish
2. **Collection Starter** - Discover 5 species
3. **Dedicated Angler** - Discover 10 species
4. **Moonlight Fisher** - Catch 5 fish at night (needs time system)
5. **Snufkin's Melody** - Fish in all locations (5 spots)
6. **Story Collector** - Discover 3 legendary fish
7. **Patient Soul** - Wait 20+ seconds before catching
8. **River Wanderer** - Fish in 5 different spots
9. **Tale of Wonder** - Catch ALL legendary fish

---

## 🐛 Common Issues & Solutions

### "Fish database not found"
- Verify `data/fish_database.json` exists
- Check file path in FishingData.gd
- Reload project (Project > Reload Current Project)

### Particles not showing
- Check catch_particles.gd is loaded
- Verify hook.gd has spawn_particles() function
- Test with Console output first

### Journal doesn't open
- Check JournalManager is in autoloads
- Verify script paths are correct
- Test with journal_button.gd on a button first

### NPCs don't accept fish
- Ensure `accepts_fish = true` in NPC inspector
- Check fish_delivery_ui script is attached
- Press **F** key (not E) near NPC

### Save data not persisting
- Check user:// folder permissions
- Look in: `%APPDATA%/Godot/app_userdata/snufkingame/`
- File should be: `fishing_data.save`

---

## 🎨 Color Palette Reference

```
# Moomin Theme Colors
Primary Background: #F5E6D3 (cream/parchment)
Secondary: #8B9D83 (sage green)
Accent: #6B8E9E (dusty blue)
Dark Text: #4A4A3A (warm grey-brown)
Borders: #8B735C (warm brown)

# Rarity Colors
Common: #999999 (gray)
Uncommon: #66B366 (green)
Rare: #6680E6 (blue)
Legendary: #D9A521 (gold)

# UI Accents
Success: #7CB37C (soft green)
Warning: #E89E3D (warm orange)
Error: #C76B6B (soft red)
Info: #6B9EC7 (calm blue)
```

---

## 🚀 Future Enhancements (Optional)

### Phase 2 Ideas:
- [ ] Time of day system (night fishing)
- [ ] Weather effects (rain increases rare spawns)
- [ ] Fishing rod upgrades
- [ ] Bait system (different baits attract different fish)
- [ ] Fishing tournaments
- [ ] Seasonal fish (spring salmon migration)
- [ ] Fish tank/aquarium (display caught fish)
- [ ] Cooking system (use fish in recipes)
- [ ] Fishing buddies (NPCs join you)
- [ ] Fishing spots map (discover new locations)

### Phase 3 Ideas:
- [ ] Multiplayer fishing sessions
- [ ] Leaderboards (optional, gentle)
- [ ] Photo mode (screenshot with caught fish)
- [ ] Fish encyclopedia with lore
- [ ] Snufkin's journal entries (unlock stories)

---

## 📝 Notes

- All systems use **Moomin aesthetic**: gentle, cozy, non-competitive
- Achievements are **personal milestones**, not hardcore challenges
- Fish delivery creates **narrative moments**, not transactional gameplay
- Collection is about **story and discovery**, not completion anxiety
- Save system is **automatic**, no manual save needed
- Scripts follow **Godot 4.x best practices**
- Signals used for **loose coupling** between systems
- Autoloads for **global state management**

---

## 🤝 Integration with Existing Game

The system integrates seamlessly:
- Uses existing `Global` autoload for consistency
- Respects dialogue system (no interruptions)
- Fish delivery uses NPC infrastructure
- Journal accessible from main menu
- Particle effects match game's visual style
- Color palette matches dialogue UI

---

**Implementation Status: ✅ COMPLETE (Backend)**
**Next Step: Create UI scenes in Godot Editor**

All scripts are ready. Just need to build the UI scenes and add fish sprites!
