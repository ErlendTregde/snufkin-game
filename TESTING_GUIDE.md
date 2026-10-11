# 🧪 How to Test the Enhanced Fishing System

## Quick Start Testing (2 minutes)

### Step 1: Add the Fishing HUD to Your Fishing Scene

1. Open `scenes/fishing_scene.tscn` in Godot
2. Click the "+" button or right-click to add a child node
3. Choose "Scene" -> "Load" and select `scenes/fishing_hud.tscn`
4. The HUD will appear - it should be at the root level (not as a child of the player)
5. Save the scene

### Step 2: Test Fishing

1. **Press F5** to run the game
2. Go to the fishing area
3. **Cast your hook** (Space)
4. **Catch some fish**

**What you should see:**
- ✅ Top-left corner: Session stats updating
- ✅ Top-right corner: Recent catches list appearing
- ✅ Center screen: "Fish name caught!" notifications
- ✅ Bottom: Collection progress bar filling up
- ✅ Console: Fish spawn messages and catch notifications

### Step 3: Test the Journal

1. While in the game, **press Backspace**
2. The fishing journal opens like a book!
3. You'll see two pages:
   - **Left page**: Common fish
   - **Right page**: Uncommon fish
4. Click "Next ▶" button to see:
   - **Left page**: Rare fish
   - **Right page**: Legendary fish
5. Click "View" button on any discovered fish to see details
6. Click "✕" to close the journal

### Step 4: Watch for Achievements

Keep catching fish and watch the console for:
```
📚 Achievement Unlocked: First Catch
📚 Achievement Unlocked: Collection Starter (after 5 species)
```

---

## What Each Rarity Looks Like

When you catch fish, they'll be colored by rarity:

- **Gray text** = Common fish (you'll catch lots)
- **Green text** = Uncommon fish (pretty common)
- **Blue text** = Rare fish (lucky!)
- **Gold text** = Legendary fish (VERY rare!)

---

## Testing the Full System

### Test 1: Catch Multiple Fish (5 minutes)

1. Catch at least **10-15 fish**
2. You should discover **3-5 species** (some will be duplicates)
3. Watch the HUD update in real-time
4. Check if "Collection Starter" achievement unlocks (5 species)

**Console output you should see:**
```
🎣 Spawned: Silver Perch (common)
🎣 New species discovered!
🎣 Spawned: Creek Minnow (common)
✨ Rare catch!
📚 Achievement Unlocked: Collection Starter
```

### Test 2: Check the Journal

1. Press **Backspace** to open journal
2. Navigate through pages with **Next/Previous** buttons
3. Click **"View"** on a discovered fish
4. Check the details:
   - Fish name and description
   - Rarity color
   - How many times you caught it
   - First catch date
   - Location hint

### Test 3: Check Save/Load

1. Catch a few fish
2. Note your collection count
3. **Close the game** (Alt+F4)
4. **Restart the game**
5. Open the journal (**Backspace**)
6. Your collection should still be there!

**Save file location:**
```
Windows: %APPDATA%/Godot/app_userdata/snufkingame/fishing_data.save
```

### Test 4: Gift Fish to NPCs (Future)

1. Catch several fish (build up inventory)
2. Go to **Moominmamma** NPC
3. Press **F** key near her
4. Gift menu opens showing your fish
5. Click "Gift" on a fish
6. Watch console for her reaction

---

## Understanding the HUD

### Top-Left Panel (Session Info)
```
Session Catches: 15     ← Total fish caught this game session
Species Found: 5/12     ← Unique species discovered
Inventory: 8 fish       ← Fish you can gift to NPCs
```

### Top-Right Panel (Recent Catches)
Shows your last 5 catches:
```
[NEW] Rainbow Trout  ← First time catching this species
Creek Minnow         ← Already discovered
Golden Carp          ← Etc.
```

### Bottom (Progress Bar)
Shows overall collection completion:
```
Collection: 42%  ← You've discovered 5 out of 12 species
```

### Center (Notifications)
Temporary messages that fade in/out:
- "NEW! Rainbow Trout" (when discovering new species)
- "Silver Perch caught!" (regular catch)
- "🏆 Achievement name" (when achievements unlock)

---

## Expected Catch Rates

Here's what to expect while fishing:

### Common Fish (40% spawn rate)
You'll catch these **very often**:
- Silver Perch
- Creek Minnow
- Pond Roach

### Uncommon Fish (15% spawn rate)
You'll catch these **regularly**:
- Rainbow Trout
- Golden Carp
- Sunset Bass

### Rare Fish (7% spawn rate)
You'll catch these **occasionally** (lucky!):
- Moon Fish
- Story Fish
- Northern Pike

### Legendary Fish (1% spawn rate)
You'll catch these **very rarely** (amazing!):
- Wanderer's Salmon
- Hattifattener Eel
- Valley Guardian

**Tip**: To catch a legendary fish faster, just keep fishing! Each cast has a 1% chance.

---

## Troubleshooting

### "I don't see the HUD"
- Make sure you added `fishing_hud.tscn` to the fishing scene
- Check it's at the root level, not inside another node
- Verify the scene is loaded (should appear in the scene tree)

### "Journal doesn't open"
- Press **Backspace** key
- Check console for errors
- Make sure FishingData and JournalManager are in autoload list

### "No fish are spawning"
- Check console for spawn messages
- Verify `fish_database.json` exists in `data/` folder
- Reload project (Project > Reload Current Project)

### "Achievements not showing"
- Look in the **console** (bottom panel in Godot)
- Achievements print there when unlocked
- GUI notification is for later

### "Progress bar shows 0%"
- Catch at least one fish first
- The bar updates after each catch
- Try reloading the scene

---

## Console Messages Guide

### Normal Messages (White)
```
✅ Fish database loaded: 12 species
✅ Fishing data loaded: 3 species discovered
```

### Fishing Messages (Blue/Green)
```
🎣 Spawned: Rainbow Trout (uncommon)
🎣 New species discovered!
✨ Rare catch!
```

### Achievement Messages (Yellow)
```
📚 Achievement Unlocked: First Catch
📚 Achievement Unlocked: Collection Starter
🏆 Achievement Unlocked: Dedicated Angler
```

### Error Messages (Red)
```
⚠️ No fish data available
❌ Failed to parse fish database JSON
```

---

## Quick Keybind Reference

| Key | Action | Context |
|-----|--------|---------|
| **Space** | Cast/Reel hook | Fishing |
| **Arrow Keys** | Move hook | While cast |
| **Enter** | Fight fish | When hooked |
| **Backspace** | Open journal | Anytime |
| **F** | Gift fish menu | Near NPC |
| **E** | Talk to NPC | Near NPC |
| **ESC** | Close UI | Any menu |

---

## Fun Testing Challenges

### Challenge 1: "The Patient Angler"
- Cast your hook
- Wait **20+ seconds** without moving
- Then catch a fish
- Unlocks "Patient Soul" achievement!

### Challenge 2: "Gotta Catch 'Em All"
- Try to discover all 12 species
- Check journal to see which are missing
- Keep fishing until you complete the collection!
- Unlocks "Dedicated Angler" achievement at 10 species

### Challenge 3: "Legendary Hunter"
- Try to catch all 3 legendary fish
- This could take **50-100+ catches** (they're 1% spawn rate)
- Watch console for gold-colored catches
- Unlocks "Tale of Wonder" achievement

---

## Expected Play Session

Here's what a typical 10-minute fishing session looks like:

**Minutes 1-2**: Catch 5-8 fish
- Mostly common (gray)
- Maybe 1 uncommon (green)
- Unlock "First Catch" achievement

**Minutes 3-5**: Catch 10-15 more fish
- Discover 3-4 new species
- Unlock "Collection Starter" achievement
- See progress bar at 30-40%

**Minutes 5-8**: Keep fishing
- Discover 2-3 more species
- Maybe catch 1 rare fish (blue)
- Progress bar at 50-60%

**Minutes 8-10**: Getting close!
- Discover 8-9 species total
- Unlock "Dedicated Angler" achievement (10 species)
- Still hunting for those legendary fish...

---

## Next Steps

Once you've tested and confirmed everything works:

1. **Draw custom fish sprites** (12 fish)
2. **Design journal book texture** (leather cover, paper pages)
3. **Create achievement badges** (pressed flowers/leaves)
4. **Add sound effects** (splashes, chimes, page turns)
5. **Polish the UI** (replace buttons with hand-drawn style)

But the game mechanics are **fully functional right now**! 🎣

---

**Have fun fishing! The system tracks everything automatically.** 🐟✨
