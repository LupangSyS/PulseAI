# Generator used to produce the D/C/B/A/S rank content in data/classes.json
# and data/cards.json from each F/E family's baseline stats. Kept as a
# reference for the design intent behind the numbers (rank multipliers,
# HP-tier increments, per-rank resource table) and the per-family flavor
# text. NOTE: this appends to the existing JSON and asserts on duplicate
# IDs, so it is NOT safe to rerun as-is now that D-S content exists; reusing
# it for a rebalance pass would need a small change to overwrite existing
# entries instead of asserting against them.

import json
import os

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

RANK_MULT = {"D": 1.25, "C": 1.45, "B": 1.7, "A": 2.0, "S": 2.4}
RESOURCE_BY_RANK = {"D": 4, "C": 5, "B": 5, "A": 6, "S": 7}
HP_STEPS = {
    "fragile": {"D": 3, "C": 4, "B": 4, "A": 5, "S": 6},
    "balanced": {"D": 4, "C": 5, "B": 5, "A": 6, "S": 7},
    "tanky": {"D": 5, "C": 6, "B": 7, "A": 8, "S": 10},
}
RANK_ORDER = ["D", "C", "B", "A", "S"]

def v(base, rank):
    return max(1, round(base * RANK_MULT[rank]))

def cumulative_hp(e_hp, tier, rank):
    total = e_hp
    for r in RANK_ORDER:
        total += HP_STEPS[tier][r]
        if r == rank:
            return total
    return total

def card(id, name, type_, class_id, cost, desc, effect, value):
    return dict(id=id, display_name=name, type=type_, class_id=class_id, cost=cost,
                description=desc, effect=effect, base_value=value, combo_tag=type_)

# Each family dict:
#  key, f_id, e_id, e_hp, hp_tier, primary_tag, secondary_tag, resource_name,
#  primary_e (anchor damage/heal value at E rank), block_e (anchor block value at E rank),
#  ranks: {"D": {...}, "C": {...}, "B": {...}, "A": {...}, "S": {...}}
#    each rank dict: display_name, locked, unlocked, playstyle,
#    cards: list of (slot, name, desc) where slot in
#      D: ["primary","dot","block","empower"]
#      C: ["primary","secondary","dot2","empower"]
#      B: ["primary","aoe","block","empower"]
#      A: ["primary","secondary2","block2","empower2"]
#      S: ["primary","execute","aoe2","empower3"]
FAMILIES = [
    dict(key="mage", e_id="naga_mage_e", e_hp=26, hp_tier="balanced",
         primary_tag="spell", secondary_tag="power", resource_name="Tide",
         primary_e=6, block_e=9, primary_effect="damage", secondary_effect="block",
         ranks=dict(
            D=dict(display_name="Tide-Marked Sorcerer",
                unlocked="The naga's blood doesn't fight you for control anymore. It answers before you finish the thought.",
                playstyle="Spell-chain caster refined: a lingering Silt Curse now scars enemies with damage that keeps ticking.",
                cards=[("primary","Tide Lance","A spear of river-water, denser than it looks."),
                       ("dot","Silt Curse","Sediment settles in the wound and doesn't stop."),
                       ("block","Scaled Ward","Naga scales thicken along your forearms."),
                       ("empower","Deep Focus","The tide pulls back before it truly breaks.")]),
            C=dict(display_name="Naga-Fang Mage",
                unlocked="Fangs grew in where teeth used to be. You didn't ask for them, and lately you don't mind them either.",
                playstyle="Fusion caster: the deck splits between Spell current and Power scale-craft, a true hybrid of mage and naga.",
                cards=[("primary","Fang Current","A bite made of moving water."),
                       ("secondary","Serpent Coil Guard","Coils of scale wrap you before the blow lands."),
                       ("dot","Venom Tide","The naga's poison rides the current now."),
                       ("empower","Ancestral Hiss","Something old and patient lends you its calm.")]),
            B=dict(display_name="Half-Naga Warlock",
                unlocked="Half your reflection is still human. The rest has scales, and it's stopped hiding when the water's still.",
                playstyle="Half-transformed caster: a river-wide Tide Wave now catches every enemy in reach.",
                cards=[("primary","Riverbreaker Bolt","A bolt with an entire river's weight behind it."),
                       ("aoe","Tide Wave","The flood doesn't pick favorites."),
                       ("block","Serpent's Hide","Skin that turns blades like river stone."),
                       ("empower","Coiled Patience","Waiting is a naga's oldest weapon.")]),
            A=dict(display_name="Eternal Tide Naga",
                unlocked="The river outside the mage school doesn't remember a version of you that wasn't like this. Most days, neither do you.",
                playstyle="Mastery tier: every Spell lands harder for the same cost. The tide simply obeys now.",
                cards=[("primary","Endless Current","A current that never really stops moving."),
                       ("dot","Undertow Rot","What it touches keeps drowning, slowly."),
                       ("block","Riverking's Shell","A shell grown, not worn."),
                       ("empower","Naga's Patience","A thousand years of waiting, briefly yours.")]),
            S=dict(display_name="Naga Avatar",
                unlocked="You stopped falling into the river a long time ago. These days, when the water rises, it rises because you're in it.",
                playstyle="Full avatar: a single Drowning Judgment can end a fight outright against anything already wounded.",
                cards=[("primary","Naga's Wrath","The river given a verdict, and a target."),
                       ("execute","Drowning Judgment","The tide doesn't ask a dying thing to keep struggling."),
                       ("aoe","Flood Reckoning","Every current in the district, at once."),
                       ("empower","Serpent-God's Calm","Nothing left to prove, so nothing left to fear.")]),
         )),
    dict(key="hunter", e_id="crocodile_warden_e", e_hp=28, hp_tier="tanky",
         primary_tag="action", secondary_tag="power", resource_name="Bite",
         primary_e=7, block_e=6, primary_effect="damage", secondary_effect="block",
         ranks=dict(
            D=dict(display_name="Canal Stalker",
                unlocked="The canal doesn't just tolerate you anymore. Things move out of your way down there now.",
                playstyle="Action-chain brawler refined: a Festering Bite now leaves a wound that keeps draining the target.",
                cards=[("primary","Jaw Lock","Grip, and don't let the current decide when it ends."),
                       ("dot","Festering Bite","A wound that doesn't want to close."),
                       ("block","Mudscale Guard","Hide thick enough to shrug off a blade."),
                       ("empower","Predator's Patience","Stillness, right up until it isn't.")]),
            C=dict(display_name="Crocodile-Fang Hunter",
                unlocked="Your canines came in wrong a while back. Sharper. You've stopped going to dentists about it.",
                playstyle="Fusion brawler: the kit splits between raw Action strikes and a Power-guarded ambush stance.",
                cards=[("primary","Fang Rush","Three strikes, all teeth."),
                       ("secondary","Ambush Plating","Scaled plating from something that waits before it wins."),
                       ("dot","Rot Current","The canal's sickness, aimed on purpose."),
                       ("empower","Cold-Blood Focus","A predator doesn't rush. It just doesn't stop.")]),
            B=dict(display_name="Half-Crocodile Ravager",
                unlocked="Half your face doesn't move like a face is supposed to anymore. The other half still smiles, when it wants to.",
                playstyle="Half-transformed brawler: a Canal Frenzy now tears into every enemy caught nearby.",
                cards=[("primary","Ravager's Bite","Full jaw, full weight, full commitment."),
                       ("aoe","Canal Frenzy","It doesn't matter how many. It matters how fast."),
                       ("block","Riverhide Plating","Armor that used to be someone else's problem."),
                       ("empower","Death Roll Instinct","An old trick, remembered by something older than you.")]),
            A=dict(display_name="Eternal Canal Predator",
                unlocked="The Klong Toey canal doesn't have monsters in it anymore. It just has you, and that's usually enough.",
                playstyle="Mastery tier: every strike lands like the first one always did, except it never stops.",
                cards=[("primary","Undying Bite","A jaw that has never once let go easily."),
                       ("dot","Endless Rot","What it touches keeps failing, long after the fight."),
                       ("block","Ancient Hide","Scales older than the flood, thicker than memory."),
                       ("empower","Apex Stillness","At the top of the food chain, waiting isn't fear.")]),
            S=dict(display_name="Crocodile Avatar",
                unlocked="You don't hunt the canal anymore. Nine years on, the canal is just where you live, and everything in it knows your name.",
                playstyle="Full avatar: a single Death Roll Verdict can end anything already bleeding.",
                cards=[("primary","Apex Predator's Strike","The whole canal's hunger, aimed at one target."),
                       ("execute","Death Roll Verdict","Once it's yours, it was always going to end this way."),
                       ("aoe","Feeding Frenzy","Everything in reach, all at once, no exceptions."),
                       ("empower","Ancient Patience","The canal has been waiting nine years. So can you.")]),
         )),
    dict(key="healer", e_id="ancestral_medium_e", e_hp=25, hp_tier="balanced",
         primary_tag="power", secondary_tag="spell", resource_name="Ancestral Faith",
         primary_e=7, block_e=7, primary_effect="heal", secondary_effect="damage",
         ranks=dict(
            D=dict(display_name="Ancestor-Touched Adept",
                unlocked="The prayers you say over the sick don't feel like prayers anymore. They feel like conversations, and something's answering.",
                playstyle="Power-chain support refined: a Withering Rebuke now weakens whatever's threatening your patient over time.",
                cards=[("primary","Ancestral Mending","Their hands, guiding yours, one more time."),
                       ("dot","Withering Rebuke","A warning that doesn't stop repeating itself."),
                       ("block","Guarding Vigil","Watched over by more people than are still alive."),
                       ("empower","Rite of Remembrance","Names spoken aloud carry more weight than you'd think.")]),
            C=dict(display_name="Spirit-Bound Medium",
                unlocked="You stopped needing to ask permission to channel them a while ago. Now they just show up when you need the hands.",
                playstyle="Fusion support: the kit splits between Power-built shields and a Spell strike borrowed from the ancestors' patience running out.",
                cards=[("primary","Bound Restoration","A healing rite spoken by more than one voice."),
                       ("secondary","Vengeful Strike","Patience has limits, even for the dead."),
                       ("dot","Grave Reckoning","An old debt, finally being collected."),
                       ("empower","Chorus of Names","Every ancestor you've ever prayed to, at once.")]),
            B=dict(display_name="Half-Ancestor Oracle",
                unlocked="You can see the tower's dead now, not just hear them. Most of them just want to help. Most.",
                playstyle="Half-transformed support: an Ancestral Reckoning now protects and punishes everything in the fight at once.",
                cards=[("primary","Oracle's Grace","A healing rite that doesn't wait to be asked."),
                       ("aoe","Ancestral Reckoning","Every debt in the room, called in at once."),
                       ("block","Veil of the Dead","A boundary the living can't cross. Neither can the enemy."),
                       ("empower","Thousand Voices","A choir doesn't hesitate. Neither do you, anymore.")]),
            A=dict(display_name="Eternal Vigil Medium",
                unlocked="The refugee towers stopped whispering your name a while back. Now they just say it out loud, like it's always been true.",
                playstyle="Mastery tier: shields hold longer, heals land bigger, and the ancestors never seem to tire.",
                cards=[("primary","Vigil's Grace","A healing rite that has never once run out."),
                       ("dot","Undying Rebuke","A punishment that outlasts the fight it started in."),
                       ("block","Eternal Ward","A boundary held by everyone who ever prayed for you."),
                       ("empower","Endless Chorus","Every voice you've ever borrowed, still here.")]),
            S=dict(display_name="Ancestor Avatar",
                unlocked="You don't channel the ancestors anymore. Somewhere along the way, without quite noticing, you became one of the ones the next medium will pray to.",
                playstyle="Full avatar: a single Final Reckoning ends what's already failing, and nothing here fights alone anymore.",
                cards=[("primary","Avatar's Grace","Every act of healing this tower has ever needed, at once."),
                       ("execute","Final Reckoning","The dead don't forgive a debt left unpaid this long."),
                       ("aoe","Communion of the Drowned","Every ancestor in the flood, called in at once."),
                       ("empower","Boundless Vigil","Nothing watched this closely has ever truly been alone.")]),
         )),
    dict(key="necromancer", e_id="bone_tide_e", e_hp=24, hp_tier="fragile",
         primary_tag="spell", secondary_tag="power", resource_name="Tide of Bones",
         primary_e=6, block_e=7, primary_effect="damage", secondary_effect="heal",
         ranks=dict(
            D=dict(display_name="Deep Bone Warden",
                unlocked="The dead outside Wat Hualamphong don't just follow you back up anymore. They wait for you to ask.",
                playstyle="Spell-chain drainer refined: a Marrow Rot curse now keeps feeding on the target long after it lands.",
                cards=[("primary","Bone Spear","A spear grown, not carved, from something that stopped needing flesh."),
                       ("dot","Marrow Rot","The cold gets in and doesn't ask to leave."),
                       ("block","Ribcage Wall","A wall of bone that used to be someone's shelter."),
                       ("empower","Whispers of the Deep","The dead have opinions about how this should go.")]),
            C=dict(display_name="Drowned-Bone Necromancer",
                unlocked="You stopped needing to dive for the dead a while ago. Now the flood just brings them to you.",
                playstyle="Fusion drainer: the kit splits between Spell current and a Power ward built from borrowed bone.",
                cards=[("primary","Drowned Current","A cold current with too many hands in it."),
                       ("secondary","Bonewrap Vigor","Borrowed strength, none of it originally yours."),
                       ("dot","Silt Marrow","The rot spreads slower than water, but it spreads."),
                       ("empower","Choir of Bones","A hundred quiet voices, all agreeing with you.")]),
            B=dict(display_name="Half-Drowned Lich",
                unlocked="Half of you stopped needing to breathe a while back. The other half still insists on it, out of habit.",
                playstyle="Half-transformed drainer: a Tide of the Drowned now drags every enemy in reach under with you.",
                cards=[("primary","Lich's Grasp","A grip that has already stopped being warm."),
                       ("aoe","Tide of the Drowned","Everyone in the water answers to the same current now."),
                       ("block","Sunken Shroud","A shroud thick enough to stop most things that still bleed."),
                       ("empower","Deathless Calm","Nothing left to fear once you've already drowned once.")]),
            A=dict(display_name="Eternal Tide Lich",
                unlocked="Wat Hualamphong doesn't flood anymore, not really. It just breathes, slowly, in and out, and you breathe with it.",
                playstyle="Mastery tier: every curse lands harder and lingers longer. The current has stopped fighting you back.",
                cards=[("primary","Endless Bone Current","A current with nine years of the drowned behind it."),
                       ("dot","Undying Marrow Rot","A rot that has stopped caring about the concept of healing."),
                       ("block","Sepulcher Wall","A wall built from everyone who never got a proper grave."),
                       ("empower","Legion's Patience","An army doesn't need to hurry. It just needs to wait.")]),
            S=dict(display_name="Drowned King Avatar",
                unlocked="You don't dive for the dead anymore. Nine years on, they surface for you, the way a court rises for a king it's still deciding whether to trust.",
                playstyle="Full avatar: a single Drowned King's Decree ends anything the tide has already claimed.",
                cards=[("primary","King's Bone Judgment","Every drowned soul in the district, lending you their grip."),
                       ("execute","Drowned King's Decree","A verdict that has been nine years in the making."),
                       ("aoe","Legion of the Deep","The whole flooded district answers the same summons."),
                       ("empower","Court of the Drowned","A king doesn't ask his court to hurry.")]),
         )),
    dict(key="assassin", e_id="yaksha_blade_e", e_hp=22, hp_tier="fragile",
         primary_tag="action", secondary_tag="power", resource_name="Yaksha's Rage",
         primary_e=7, block_e=6, primary_effect="damage", secondary_effect="block",
         ranks=dict(
            D=dict(display_name="Temple-Marked Blade",
                unlocked="The guardian statue's mark on your arm hasn't faded. If anything, it's gotten more detailed.",
                playstyle="Action-chain burst refined: a Cursed Edge wound now keeps bleeding long after the cut.",
                cards=[("primary","Marked Strike","A cut that remembers the statue it came from."),
                       ("dot","Cursed Edge","A wound that isn't interested in closing."),
                       ("block","Temple Reflexes","Stillness a guardian statue would recognize."),
                       ("empower","Guardian's Focus","A breath borrowed from something that's stood still for centuries.")]),
            C=dict(display_name="Yaksha-Fang Assassin",
                unlocked="Your reflection in still water doesn't quite match anymore. It's not wrong. It's just older than you.",
                playstyle="Fusion assassin: the kit splits between fast Action strikes and a Power-guarded demon stance.",
                cards=[("primary","Fang of the Guardian","Faster than the eye tracks, same as the statue always promised."),
                       ("secondary","Demon's Bulwark","A guardian's stance, borrowed without asking."),
                       ("dot","Temple Venom","Poison that tastes faintly of old incense."),
                       ("empower","Still Water Focus","The moment before the strike, held a little longer.")]),
            B=dict(display_name="Half-Yaksha Reaver",
                unlocked="Half your shadow doesn't match your shape anymore, most nights. You've learned not to look at it directly.",
                playstyle="Half-transformed reaver: a Guardian's Wrath now cuts down every enemy in the room.",
                cards=[("primary","Reaver's Cut","A strike with a temple guardian's full weight behind it."),
                       ("aoe","Guardian's Wrath","The demon inside the statue never liked being outnumbered."),
                       ("block","Yaksha Hide","Skin the color of old temple stone, twice as hard."),
                       ("empower","Demon-Marked Calm","Rage that has learned, finally, to wait.")]),
            A=dict(display_name="Eternal Guardian Blade",
                unlocked="The drowned wat in Thonburi doesn't need a statue anymore. It has you, and you don't mind the job.",
                playstyle="Mastery tier: every strike carries a guardian's full weight, and none of it costs more than it used to.",
                cards=[("primary","Undying Guardian's Cut","A strike that has stood watch for longer than the flood."),
                       ("dot","Eternal Temple Venom","A poison older than the mark it came from."),
                       ("block","Ancient Guardian Plating","Stone-hard skin that remembers a temple that no longer stands."),
                       ("empower","Millennium Patience","A guardian doesn't rush. It's had centuries not to.")]),
            S=dict(display_name="Yaksha Avatar",
                unlocked="You stopped being the statue's new vessel a long time ago. These days, when something needs guarding, the city just sends them to you.",
                playstyle="Full avatar: a single Guardian's Final Verdict ends anything already cornered.",
                cards=[("primary","Avatar's Reckoning","Every guardian this city has ever needed, in one strike."),
                       ("execute","Guardian's Final Verdict","A verdict a temple guardian has never once reconsidered."),
                       ("aoe","Demon-King's Wrath","Every threat in the room, judged at once."),
                       ("empower","Stonebound Serenity","Nothing left to prove, after this many centuries.")]),
         )),
    dict(key="tank", e_id="erawan_guardian_e", e_hp=38, hp_tier="tanky",
         primary_tag="power", secondary_tag="action", resource_name="Threefold Resolve",
         primary_e=6, block_e=9, primary_effect="damage", secondary_effect="block",
         ranks=dict(
            D=dict(display_name="Threefold Bulwark",
                unlocked="Three heads' worth of will doesn't get tired the way one does. You're starting to understand what that actually means.",
                playstyle="Power-chain wall refined: a Guardian's Brand now wears down anything foolish enough to keep attacking.",
                cards=[("primary","Bulwark Strike","A shield swung like it's still meant to protect someone."),
                       ("dot","Guardian's Brand","A mark that keeps testing what it's stamped on."),
                       ("block","Threefold Stance","Three directions watched, none of them unguarded."),
                       ("empower","Shrine Resolve","A shrine that survived a flood doesn't flinch at much.")]),
            C=dict(display_name="Erawan-Bound Warden",
                unlocked="You don't need the shrine anymore, not really. Wherever you plant your feet, that's the ground it's protecting now.",
                playstyle="Fusion guardian: the kit splits between a Power wall and an Action-tagged counter-charge.",
                cards=[("primary","Bound Bulwark","A wall with three minds' worth of stubbornness."),
                       ("secondary","Trunk Charge","Three heads deciding, all at once, to stop being patient."),
                       ("dot","Shrine's Judgment","A verdict the shrine has been considering for years."),
                       ("empower","Threefold Will","One will refusing isn't much. Three refusing is a wall.")]),
            B=dict(display_name="Half-Erawan Colossus",
                unlocked="You don't fit through most doorways anymore, not comfortably. Nobody's complained yet. Nobody's tried.",
                playstyle="Half-transformed colossus: a Threefold Judgment now punishes every enemy that dared get close.",
                cards=[("primary","Colossus Slam","A strike with the weight of something that used to be a shrine."),
                       ("aoe","Threefold Judgment","Three heads don't miss, even when they're aiming at everyone."),
                       ("block","Colossal Hide","Armor grown, not forged, from something that's stopped being purely human."),
                       ("empower","Unshaken Resolve","A colossus doesn't flinch. It's forgotten how.")]),
            A=dict(display_name="Eternal Threefold Guardian",
                unlocked="The intersection at Ratchaprasong doesn't flood the way it used to. It just has you standing in it, and that seems to be enough.",
                playstyle="Mastery tier: block stacks higher than ever, and nothing gets through unnoticed anymore.",
                cards=[("primary","Undying Bulwark Strike","A shield strike backed by nine years of not falling."),
                       ("dot","Eternal Shrine Judgment","A verdict that has stopped being interested in mercy."),
                       ("block","Sacred Threefold Wall","A wall three minds have sworn to hold."),
                       ("empower","Ancient Vow","A vow made to a shrine that never really washed away.")]),
            S=dict(display_name="Erawan Avatar",
                unlocked="You stopped guarding the shrine a long time ago. Nine years on, people just call the intersection by your name instead of the shrine's.",
                playstyle="Full avatar: a single Threefold Reckoning ends anything already failing to get past you.",
                cards=[("primary","Avatar's Bulwark","Everything the shrine ever protected, standing behind one strike."),
                       ("execute","Threefold Reckoning","Three heads agreeing is a verdict nothing survives."),
                       ("aoe","Guardian's Last Stand","Every threat at this intersection, met at once."),
                       ("empower","Unbroken Vow","A vow this old doesn't need reminding.")]),
         )),
    dict(key="berserker", e_id="rakshasa_fury_e", e_hp=30, hp_tier="tanky",
         primary_tag="action", secondary_tag="power", resource_name="Demon's Fury",
         primary_e=8, block_e=4, primary_effect="damage", secondary_effect="block",
         ranks=dict(
            D=dict(display_name="Demon-Marked Brawler",
                unlocked="The mask doesn't come off clean anymore. There's a mark underneath now, whether or not you're wearing it.",
                playstyle="Action-chain glass cannon refined: a Demon's Grudge wound now keeps hurting long after the punch lands.",
                cards=[("primary","Marked Haymaker","A punch with a demon-king's temper behind it."),
                       ("dot","Demon's Grudge","An old fury doesn't let a wound heal clean."),
                       ("block","Mask's Ward","Borrowed stubbornness, worn like armor."),
                       ("empower","Rising Temper","Something underneath is getting harder to ignore.")]),
            C=dict(display_name="Rakshasa-Fanged Berserker",
                unlocked="You don't need the mask in the pit anymore. Half the time you forget to bring it, and nobody's noticed the difference.",
                playstyle="Fusion berserker: the kit splits between raw Action fury and a Power-guarded demon stance.",
                cards=[("primary","Fanged Fury","Ten arms' worth of temper, thrown through two."),
                       ("secondary","Demon-King's Guard","A stance a king wouldn't be ashamed of."),
                       ("dot","Rakshasa's Curse","An old grudge, freshly reopened."),
                       ("empower","Boiling Patience","Patience, for a demon king, is measured in seconds.")]),
            B=dict(display_name="Half-Rakshasa Ravager",
                unlocked="Ten arms would be an exaggeration. Four isn't, most nights, and nobody in the pit argues about it anymore.",
                playstyle="Half-transformed ravager: a Tenfold Ruin now flattens every enemy in reach.",
                cards=[("primary","Ravager's Ruin","A blow that doesn't care how many hands it needed."),
                       ("aoe","Tenfold Ruin","Every arm, every direction, all at once."),
                       ("block","Demon Plating","Skin a war was fought over, once."),
                       ("empower","King's Boiling Fury","A fury this old doesn't ask permission to rise.")]),
            A=dict(display_name="Eternal Demon-King Fury",
                unlocked="The fight pit under the old expressway doesn't have a champion anymore. It just has you, and everyone else takes turns losing.",
                playstyle="Mastery tier: every strike lands with a king's full weight, and the fury never runs dry.",
                cards=[("primary","Undying King's Blow","A blow a demon king would recognize as his own."),
                       ("dot","Eternal Grudge","A curse that has stopped bothering to fade."),
                       ("block","Ancient War-Hide","Armor from a war most people have forgotten happened."),
                       ("empower","Boundless Temper","A temper this old has stopped needing a reason.")]),
            S=dict(display_name="Rakshasa Avatar",
                unlocked="You don't wear the mask into the pit anymore. Nine years on, the pit just clears out when it hears you coming, mask or not.",
                playstyle="Full avatar: a single King's Judgment ends anything already staggered.",
                cards=[("primary","Avatar's Ruin","A demon-king's full fury, in one arm's swing."),
                       ("execute","King's Judgment","A verdict a war of demons was fought and settled over."),
                       ("aoe","Tosakanth's Wrath","Ten arms, one temper, everyone in range."),
                       ("empower","Unbroken King's Calm","A king doesn't need to prove anything, this far in.")]),
         )),
    dict(key="summoner", e_id="kuman_thong_e", e_hp=24, hp_tier="balanced",
         primary_tag="power", secondary_tag="spell", resource_name="Bond",
         primary_e=7, block_e=8, primary_effect="damage", secondary_effect="block",
         ranks=dict(
            D=dict(display_name="Bonded Warden",
                unlocked="Little brother doesn't wait to be called anymore. He just shows up, usually right when you need him to.",
                playstyle="Power-chain summoner refined: a Mischief Curse now wears the enemy down while little brother keeps you safe.",
                cards=[("primary","Bonded Strike","Two strikes, thrown by only one of you."),
                       ("dot","Mischief Curse","He thinks this part is funny. It's still working."),
                       ("block","Sibling's Shield","He steps in front of you without being asked, every time."),
                       ("empower","Whispered Encouragement","He's got opinions about your technique. Mostly good ones.")]),
            C=dict(display_name="Kuman-Marked Summoner",
                unlocked="You stopped needing the spirit house months ago. These days he just follows, the way a little brother does.",
                playstyle="Fusion summoner: the kit splits between a Power-built bond and a Spell strike he lends you outright.",
                cards=[("primary","Marked Bond","A strike thrown with someone else's small hands helping."),
                       ("secondary","Brother's Ward","A ward he insists on building himself."),
                       ("dot","Playful Rot","He's still figuring out that some tricks shouldn't be funny."),
                       ("empower","Shared Mischief","Two of you, agreeing on the plan, for once.")]),
            B=dict(display_name="Half-Spirit Conjurer",
                unlocked="Some days you're not entirely sure where you end and he begins. He seems to find that funnier than you do.",
                playstyle="Half-transformed conjurer: a Brotherhood's Reckoning now hits everything in the fight at once.",
                cards=[("primary","Conjurer's Strike","A strike neither of you is entirely sure whose it was."),
                       ("aoe","Brotherhood's Reckoning","He doesn't believe in leaving anyone out."),
                       ("block","Twin Ward","A shield built by two sets of hands, one of them very small."),
                       ("empower","Inseparable Focus","Neither of you has ever really fought alone.")]),
            A=dict(display_name="Eternal Bond Warden",
                unlocked="The spirit house on the rooftop is long gone. You never needed to rebuild it. He was never really tied to the house.",
                playstyle="Mastery tier: the bond holds stronger than ever, and every strike lands with two sets of will behind it.",
                cards=[("primary","Undying Bonded Strike","A strike backed by a bond nothing has managed to break."),
                       ("dot","Eternal Mischief Curse","A trick he's had nine years to perfect."),
                       ("block","Ancient Sibling's Shield","A shield he's stood behind for longer than either of you admits."),
                       ("empower","Boundless Trust","Trust this old doesn't need to be asked for.")]),
            S=dict(display_name="Kuman Thong Avatar",
                unlocked="You don't summon him anymore. Nine years on, when people say your name, half the time they mean both of you.",
                playstyle="Full avatar: a single Brothers' Verdict can end anything already reeling.",
                cards=[("primary","Avatar's Bond","Everything the two of you have built, thrown as one."),
                       ("execute","Brothers' Verdict","He's decided. That's usually enough, by now."),
                       ("aoe","Spirit-House Reckoning","Every offering ever given, called back in at once."),
                       ("empower","Unshakeable Bond","A bond this deep doesn't need reminding it's real.")]),
         )),
    dict(key="pyromancer", e_id="garuda_ember_e", e_hp=22, hp_tier="fragile",
         primary_tag="spell", secondary_tag="power", resource_name="Sunfire",
         primary_e=8, block_e=6, primary_effect="damage", secondary_effect="block",
         ranks=dict(
            D=dict(display_name="Solar-Marked Pyromancer",
                unlocked="The mural's fire doesn't just answer when you call it now. It's started answering before you finish asking.",
                playstyle="Spell-chain burst caster refined: a Sunscar Brand now keeps burning long after the initial blast.",
                cards=[("primary","Solar Bolt","A bolt with a palace mural's memory of the sun in it."),
                       ("dot","Sunscar Brand","A burn a mural remembered for six years underwater."),
                       ("block","Heatveil Guard","Air so hot the blow doesn't quite land clean."),
                       ("empower","Mural's Memory","The wall remembered the sun longer than the sun remembered it.")]),
            C=dict(display_name="Garuda-Wing Pyromancer",
                unlocked="Something like feathers is starting to show at the edge of the burns. You've stopped trying to explain it to people.",
                playstyle="Fusion caster: the kit splits between Spell fire and a Power-guarded wingbeat of heat.",
                cards=[("primary","Wingfire Bolt","A bolt thrown like it has somewhere further to go."),
                       ("secondary","Sundisc Plating","A disc of solar fire, worn instead of thrown."),
                       ("dot","Feathered Ember","A coal that keeps finding new places to catch."),
                       ("empower","Sun-Eagle's Patience","Something with wings doesn't need to rush the strike.")]),
            B=dict(display_name="Half-Garuda Flamebearer",
                unlocked="You don't remember deciding to grow wings. You just remember the first time you used them, and not falling.",
                playstyle="Half-transformed flamebearer: a Sunwing Eruption now burns everything caught in the blast.",
                cards=[("primary","Flamebearer's Strike","A strike carried further than an arm should reach."),
                       ("aoe","Sunwing Eruption","Fire enough to dry nine years of flood in one gust."),
                       ("block","Sun-Feathered Hide","Scales and feathers, both immune to most of what burns."),
                       ("empower","Half-Sky Focus","Somewhere between the ground and the sun, focus is easy.")]),
            A=dict(display_name="Eternal Sunfire Knight",
                unlocked="The old palace mural doesn't flake anymore. Divers say it looks freshly painted, and they're right, in a way none of them expect.",
                playstyle="Mastery tier: every bolt lands with a myth's full weight, and the fire never seems to gutter.",
                cards=[("primary","Undying Solar Bolt","A bolt carrying a sun that has never once gone out."),
                       ("dot","Eternal Sunscar","A burn a myth has had centuries to perfect."),
                       ("block","Ancient Sundisc Guard","A disc forged from a fire older than the palace it's painted on."),
                       ("empower","Boundless Solar Focus","A sun-eagle doesn't hesitate before a dive.")]),
            S=dict(display_name="Garuda Avatar",
                unlocked="You don't channel the mural's fire anymore. Nine years on, when the sky over the flooded district catches light at dusk, people just say your name.",
                playstyle="Full avatar: a single Sun-Eagle's Verdict ends anything already scorched.",
                cards=[("primary","Avatar's Sunfire","A myth's entire memory of the sun, aimed at one target."),
                       ("execute","Sun-Eagle's Verdict","The sun doesn't negotiate with something already burning."),
                       ("aoe","Garuda's Descent","The whole sky over the district, coming down at once."),
                       ("empower","Eternal Sun's Calm","Nothing left to prove, this close to the sun.")]),
         )),
    dict(key="ranger", e_id="hanuman_ranger_e", e_hp=25, hp_tier="balanced",
         primary_tag="action", secondary_tag="power", resource_name="Leaping Wind",
         primary_e=7, block_e=5, primary_effect="damage", secondary_effect="block",
         ranks=dict(
            D=dict(display_name="Windrunning Adept",
                unlocked="You don't miss a landing anymore. Not once, not since the jump that shouldn't have worked.",
                playstyle="Action-chain skirmisher refined: a Wind-Cut Wound now keeps the target bleeding tempo it can't spare.",
                cards=[("primary","Windrunner's Shot","An arrow that arrives before the draw looks finished."),
                       ("dot","Wind-Cut Wound","A cut the wind keeps reopening."),
                       ("block","Skybridge Reflex","Never in one place long enough to be hit properly."),
                       ("empower","Monkey's Patience","A grin that's been unsettling things since before the city had a name.")]),
            C=dict(display_name="Hanuman-Marked Ranger",
                unlocked="Your shadow moves a beat before you do, most days. You've stopped trying to catch it doing that.",
                playstyle="Fusion ranger: the kit splits between fast Action shots and a Power-guarded leap.",
                cards=[("primary","Marked Volley","Three shots, none of them where you were standing."),
                       ("secondary","Leaping Guard","A stance built for landing, not staying still."),
                       ("dot","Windborne Venom","Poison that travels faster than it should."),
                       ("empower","Sky-Sent Focus","A breath taken mid-leap, somehow steady anyway.")]),
            B=dict(display_name="Half-Hanuman Skyrunner",
                unlocked="You cleared four towers in one jump last week. Nobody who saw it has fully explained it to themselves yet.",
                playstyle="Half-transformed skyrunner: a Monkey-God's Volley now catches every enemy across the field.",
                cards=[("primary","Skyrunner's Strike","A strike thrown mid-leap, landing before the leap does."),
                       ("aoe","Monkey-God's Volley","An old god's aim doesn't play favorites."),
                       ("block","Windbound Hide","Skin that's stopped taking most falls seriously."),
                       ("empower","Impossible Leap Focus","The jump that shouldn't work, made a habit.")]),
            A=dict(display_name="Eternal Windstep Ranger",
                unlocked="The skybridges between towers don't feel far anymore. Nine years of running them will do that, apparently.",
                playstyle="Mastery tier: every shot lands with a monkey-god's aim, and the wind never seems to slow you.",
                cards=[("primary","Undying Windrunner's Shot","A shot that hasn't missed since the jump that started this."),
                       ("dot","Eternal Wind-Cut","A wound the wind has had years to perfect."),
                       ("block","Ancient Skybridge Reflex","Reflexes older than the bridges they were built on."),
                       ("empower","Boundless Leap","A leap this old doesn't need to be aimed anymore.")]),
            S=dict(display_name="Hanuman Avatar",
                unlocked="You don't run the skybridges anymore. Nine years on, when something impossible needs doing between two towers, people just say your name.",
                playstyle="Full avatar: a single Monkey-God's Verdict ends anything already caught mid-fall.",
                cards=[("primary","Avatar's Volley","Every leap you've ever survived, loosed as one shot."),
                       ("execute","Monkey-God's Verdict","An old god's grin, right before the strike lands."),
                       ("aoe","Skyfall Reckoning","Every rooftop in reach, at once."),
                       ("empower","Boundless Grin","Nothing left to prove, this many towers in.")]),
         )),
    dict(key="monk", e_id="sak_yant_e", e_hp=27, hp_tier="balanced",
         primary_tag="action", secondary_tag="power", resource_name="Yantra",
         primary_e=7, block_e=6, primary_effect="damage", secondary_effect="block",
         ranks=dict(
            D=dict(display_name="Yantra-Bound Fighter",
                unlocked="The ink doesn't just sit on your skin anymore. It moves, sometimes, right before you do.",
                playstyle="Action-chain striker refined: a Cursed Yantra Wound now keeps draining whatever it marks.",
                cards=[("primary","Bound Elbow","An elbow strike with sacred script behind it."),
                       ("dot","Cursed Yantra Wound","A mark that keeps collecting on an old debt."),
                       ("block","Tiger-Ink Guard","Ink that turns blades, most of the time."),
                       ("empower","Kru's Reminder","A lesson half-remembered, still holding up.")]),
            C=dict(display_name="Sacred-Ink Adept",
                unlocked="You stopped counting the tattoos a while ago. The ink stopped needing your permission to add more, too.",
                playstyle="Fusion striker: the kit splits between fast Action strikes and a Power-guarded ward stance.",
                cards=[("primary","Adept's Combo","Five lines, five strikes, one breath, same as always."),
                       ("secondary","Warded Stance","A stance the ink insists on, more than you do."),
                       ("dot","Script Rot","A curse written faster than it can be read."),
                       ("empower","Ruesi's Focus","A hermit sage's patience, borrowed for one breath.")]),
            B=dict(display_name="Half-Spirit Yantra Warrior",
                unlocked="Your shadow has lines on it now, the same ones as your skin. You've stopped questioning who drew those.",
                playstyle="Half-transformed warrior: a Five-Row Reckoning now marks every enemy caught in range.",
                cards=[("primary","Warrior's Strike","A strike with a spirit's full weight behind the ink."),
                       ("aoe","Five-Row Reckoning","Sacred script, read out loud, to everyone at once."),
                       ("block","Spirit-Marked Hide","Skin the ink has stopped needing permission to protect."),
                       ("empower","Half-Sacred Calm","Somewhere between a man and a mark, calm is easy.")]),
            A=dict(display_name="Eternal Yantra Master",
                unlocked="The old shophouse where you got the first tattoo flooded over years ago. The ink doesn't need the shop anymore. It never really did.",
                playstyle="Mastery tier: every strike lands with a master's full weight, and the ink has stopped needing to be earned twice.",
                cards=[("primary","Undying Bound Strike","A strike carrying every tattoo you've ever earned."),
                       ("dot","Eternal Script Rot","A curse a master's ink has had years to refine."),
                       ("block","Ancient Tiger-Ink Guard","Ink older than the shophouse it came from."),
                       ("empower","Boundless Kru's Wisdom","A lesson this old doesn't need repeating.")]),
            S=dict(display_name="Yantra Avatar",
                unlocked="You don't need new ink anymore. Nine years on, the sacred script covers you completely, and it's stopped being a metaphor.",
                playstyle="Full avatar: a single Master's Final Verdict ends anything already marked.",
                cards=[("primary","Avatar's Combo","Every lesson, every mark, thrown as one unbroken strike."),
                       ("execute","Master's Final Verdict","A verdict written in ink that has never once been wrong."),
                       ("aoe","Sacred Script Reckoning","Every line of ink on your body, read at once."),
                       ("empower","Unbroken Ruesi's Calm","A hermit sage's serenity, no longer borrowed.")]),
         )),
    dict(key="alchemist", e_id="mutagen_alchemist_e", e_hp=23, hp_tier="fragile",
         primary_tag="power", secondary_tag="spell", resource_name="Catalyst",
         primary_e=6, block_e=6, primary_effect="damage", secondary_effect="block",
         ranks=dict(
            D=dict(display_name="Current-Touched Alchemist",
                unlocked="The batches don't fail anymore, not the way they used to. They just... change, into something you didn't quite plan for.",
                playstyle="Volatile mixer refined: a Corroding Draft now keeps eating away at whatever it touches.",
                cards=[("primary","Current Flask","Bottled current, thrown before it decides to destabilize."),
                       ("dot","Corroding Draft","A mixture that hasn't finished reacting yet."),
                       ("block","Hardening Dose","Skin like cooling glass, held a little longer."),
                       ("empower","Unstable Focus","Shake first. You've learned that the hard way, repeatedly.")]),
            C=dict(display_name="Catalyst-Bound Chemist",
                unlocked="You stopped needing the stall a while back. These days the reagents mostly find you.",
                playstyle="Fusion mixer: the kit splits between a Power-primed brew and a Spell cast the moment it's ready.",
                cards=[("primary","Bound Catalyst","A mixture primed and thrown in the same motion."),
                       ("secondary","Reactive Ward","A brew that hardens on contact, mostly on purpose."),
                       ("dot","Volatile Rot","A reaction that hasn't decided when to stop."),
                       ("empower","Steady Hands","Hands that have stopped shaking, mostly out of practice.")]),
            B=dict(display_name="Half-Mutated Alchemist",
                unlocked="Your veins glow faintly now, when the current under the city runs strong. You've stopped covering them up.",
                playstyle="Half-transformed mixer: a Catalytic Bloom now spreads across every enemy in the blast radius.",
                cards=[("primary","Mutated Strike","A throw that doesn't miss the way it used to."),
                       ("aoe","Catalytic Bloom","A reaction that doesn't believe in staying contained."),
                       ("block","Glassy Hide","Skin cooled from something that used to be liquid."),
                       ("empower","Mutation's Clarity","Everything is obvious, once the current stops arguing with you.")]),
            A=dict(display_name="Eternal Catalyst Alchemist",
                unlocked="The market stall is gone, washed out years ago. You don't need a stall. You are, more or less, the reaction now.",
                playstyle="Mastery tier: every brew lands harder, and the reagents never seem to run short anymore.",
                cards=[("primary","Undying Current Flask","A flask holding a current that refuses to settle."),
                       ("dot","Eternal Corrosion","A reaction that stopped needing new reagents to keep going."),
                       ("block","Ancient Hardened Glass","Glass cooled from a reaction older than the market it was sold in."),
                       ("empower","Boundless Steady Hands","Hands that have stopped needing to be steadied.")]),
            S=dict(display_name="Current Avatar",
                unlocked="You don't brew from the current anymore. Nine years on, the current under Bangkok just runs a little stronger wherever you're standing.",
                playstyle="Full avatar: a single Catalytic Verdict ends anything already destabilized.",
                cards=[("primary","Avatar's Reaction","Every batch you've ever brewed, thrown as one."),
                       ("execute","Catalytic Verdict","A reaction that doesn't stop until it's finished the job."),
                       ("aoe","Current Unbound","The mystic current itself, let off its leash."),
                       ("empower","Boundless Clarity","Nothing left to shake. Nothing left to doubt.")]),
         )),
    dict(key="psychic", e_id="resonant_e", e_hp=22, hp_tier="fragile",
         primary_tag="spell", secondary_tag="power", resource_name="Resonance",
         primary_e=7, block_e=7, primary_effect="damage", secondary_effect="block",
         ranks=dict(
            D=dict(display_name="Deep Resonant Adept",
                unlocked="The current under the city doesn't feel like static anymore. It feels like something with an opinion, and it's started sharing them.",
                playstyle="Spell-chain telekinetic refined: a Fracturing Thought now keeps unraveling whatever it's aimed at.",
                cards=[("primary","Resonant Strike","A thought insisted upon hard enough to leave a bruise."),
                       ("dot","Fracturing Thought","A crack that keeps spreading, quietly, on its own."),
                       ("block","Deep Ward","A wall built from certainty, mostly borrowed."),
                       ("empower","Current's Clarity","Everything is quieter, once you stop fighting the noise.")]),
            C=dict(display_name="Current-Bound Psychic",
                unlocked="You stopped needing to concentrate to hear it a while ago. Now it's more like it's always half-talking, and you're half-listening back.",
                playstyle="Fusion psychic: the kit splits between Spell force and a Power-built mental ward.",
                cards=[("primary","Bound Pressure Wave","A wave thrown with the current's own weight behind it."),
                       ("secondary","Current's Barrier","A wall the current builds without being asked."),
                       ("dot","Static Fracture","A crack the current keeps widening for you."),
                       ("empower","Twinned Focus","Two minds agreeing is faster than one deciding.")]),
            B=dict(display_name="Half-Resonant Oracle",
                unlocked="You don't always know anymore which thoughts started in your own head. Most days that stopped mattering.",
                playstyle="Half-transformed oracle: a Current's Verdict now unravels every enemy caught in its reach.",
                cards=[("primary","Oracle's Crush","A thought insisted upon with the current standing behind it."),
                       ("aoe","Current's Verdict","The current doesn't believe in leaving anyone out."),
                       ("block","Resonant Hide","A ward that thinks faster than a blow can land."),
                       ("empower","Half-Current Clarity","Somewhere between a mind and a current, focus is easy.")]),
            A=dict(display_name="Eternal Resonance Adept",
                unlocked="The noise stopped being noise years ago. It's just conversation now, one you've been having for so long you've forgotten it started as static.",
                playstyle="Mastery tier: every thought lands with the current's full weight, and the resonance never seems to fade.",
                cards=[("primary","Undying Resonant Strike","A strike carrying a current that has never once gone quiet."),
                       ("dot","Eternal Fracture","A crack the current has had years to perfect."),
                       ("block","Ancient Current Ward","A ward built from a certainty older than the Release."),
                       ("empower","Boundless Current Focus","Focus that has stopped needing to be reached for.")]),
            S=dict(display_name="Resonance Avatar",
                unlocked="You don't listen for the current anymore. Nine years on, when the current under Bangkok speaks, more often than not it's using your voice.",
                playstyle="Full avatar: a single Current's Final Word ends anything already fracturing.",
                cards=[("primary","Avatar's Resonance","Every thought the current has ever lent you, at once."),
                       ("execute","Current's Final Word","The current doesn't repeat itself for something already breaking."),
                       ("aoe","Citywide Fracture","Every mind in range, touched by the same current."),
                       ("empower","Boundless Clarity","Nothing left unclear, this deep into the resonance.")]),
         )),
    dict(key="exorcist", e_id="drowned_khru_e", e_hp=25, hp_tier="balanced",
         primary_tag="spell", secondary_tag="power", resource_name="Merit",
         primary_e=7, block_e=7, primary_effect="damage", secondary_effect="block",
         ranks=dict(
            D=dict(display_name="Boundary-Marked Khru",
                unlocked="The sutras don't feel unfinished anymore. They feel like they were always going to end up complete, with or without a teacher to finish them.",
                playstyle="Spell-chain purifier refined: a Binding Sutra now keeps weakening whatever it's spoken over.",
                cards=[("primary","Marked Sutra Strike","A verse that has stopped needing to be perfect to work."),
                       ("dot","Binding Sutra","A verse that keeps repeating itself, quietly, on its own."),
                       ("block","Boundary Ward","A line drawn between worlds, and you're standing on the safe side."),
                       ("empower","Merit's Weight","Good deeds, it turns out, actually add up to something.")]),
            C=dict(display_name="Spirit-Bound Exorcist",
                unlocked="You don't fully banish them anymore, not always. Sometimes you just ask what they need, and that works better than expected.",
                playstyle="Fusion exorcist: the kit splits between Spell purification and a Power-built boundary ward.",
                cards=[("primary","Bound Purification","A rite spoken with more than one voice behind it."),
                       ("secondary","Spirit's Truce","A ward built on an agreement instead of a fight."),
                       ("dot","Wandering Curse","A restless thing, finally given somewhere to go."),
                       ("empower","Negotiated Merit","Sometimes the boundary bends easier than it breaks.")]),
            B=dict(display_name="Half-Spirit Khru",
                unlocked="You're not entirely on the living side of the boundary anymore, not fully. Neither are you entirely gone. It's a useful place to stand.",
                playstyle="Half-transformed khru: a Boundary's Judgment now purifies every threat caught between worlds.",
                cards=[("primary","Khru's Reckoning","A rite spoken from somewhere between two worlds."),
                       ("aoe","Boundary's Judgment","The line between worlds doesn't play favorites."),
                       ("block","Threshold Hide","Skin that belongs, a little, to both sides of the line."),
                       ("empower","Half-Boundary Calm","Standing between two worlds is calmer than it sounds.")]),
            A=dict(display_name="Eternal Boundary Khru",
                unlocked="The old teacher's unfinished lesson plan doesn't feel unfinished anymore. You've been teaching yourself out of it for nine years, and it shows.",
                playstyle="Mastery tier: every rite lands with a completed ordination's full weight, and the boundary holds without strain.",
                cards=[("primary","Undying Marked Sutra","A verse that has never once needed to be repeated."),
                       ("dot","Eternal Binding","A binding that has had years to become unbreakable."),
                       ("block","Ancient Boundary Ward","A line between worlds, held for nine years without slipping."),
                       ("empower","Boundless Merit","Merit that stopped needing to be counted, long ago.")]),
            S=dict(display_name="Boundary Avatar",
                unlocked="You don't guard the line between worlds anymore. Nine years on, wherever you're standing, that's just where the line is.",
                playstyle="Full avatar: a single Final Ordination ends anything still clinging to this side of the boundary.",
                cards=[("primary","Avatar's Sutra","Every rite you've ever spoken, completed in one breath."),
                       ("execute","Final Ordination","A verdict the boundary itself has already agreed to."),
                       ("aoe","Boundary's Reckoning","Every restless thing in reach, judged at once."),
                       ("empower","Boundless Serenity","Nothing left unresolved, this close to the line.")]),
         )),
    dict(key="bard", e_id="broadcast_wraith_e", e_hp=23, hp_tier="fragile",
         primary_tag="power", secondary_tag="spell", resource_name="Broadcast",
         primary_e=7, block_e=6, primary_effect="damage", secondary_effect="block",
         ranks=dict(
            D=dict(display_name="Deep Signal Adept",
                unlocked="You don't need the 3 a.m. slot anymore. The signal answers whenever you reach for it now, day or night.",
                playstyle="Power-chain enabler refined: a Fading Frequency now keeps draining whatever it's tuned to.",
                cards=[("primary","Signal Burst","A shriek of feedback tuned to land, not just to hurt."),
                       ("dot","Fading Frequency","A frequency that keeps eating its own signal, slowly."),
                       ("block","Static Veil","Noise thick enough to hide behind."),
                       ("empower","Dead Station Focus","A station nobody runs anymore, still somehow broadcasting.")]),
            C=dict(display_name="Frequency-Bound Wraith",
                unlocked="You stopped needing the transmitter's power source a while back. You're not sure what's powering it now, and you've stopped asking.",
                playstyle="Fusion herald: the kit splits between a Power-primed broadcast and a Spell burst it pays off.",
                cards=[("primary","Bound Feedback","A burst thrown the moment the frequency's primed."),
                       ("secondary","Jammed Frequency","A defensive hum tuned to drown out an attack."),
                       ("dot","Corrupted Signal","A frequency that keeps degrading whatever it touches."),
                       ("empower","Tuned Amplitude","Cranked further than the old dial ever safely went.")]),
            B=dict(display_name="Half-Signal Herald",
                unlocked="Half your voice doesn't sound like yours over the old emergency band anymore. People say it's clearer than it's ever been.",
                playstyle="Half-transformed herald: a Citywide Broadcast now reaches every threat in range at once.",
                cards=[("primary","Herald's Scream","A scream carried on every frequency that'll take it."),
                       ("aoe","Citywide Broadcast","Half the towers in range hear this one, whether they want to or not."),
                       ("block","Signal-Woven Hide","Static thick enough to blur most incoming hits."),
                       ("empower","Broadcast Instinct","You don't need the dial anymore. You just know where to aim.")]),
            A=dict(display_name="Eternal Broadcast Herald",
                unlocked="The dead station went off the air in 2026. Nine years later, it's never really stopped broadcasting. It just stopped needing the building.",
                playstyle="Mastery tier: every burst lands with a station's full power, and the signal never seems to fade.",
                cards=[("primary","Undying Signal Burst","A burst carrying a frequency that has never once gone dead."),
                       ("dot","Eternal Corruption","A degrading signal that has had years to spread."),
                       ("block","Ancient Static Veil","Noise thick enough to have hidden things for nine years."),
                       ("empower","Boundless Amplitude","An amplitude that stopped needing a dial to reach.")]),
            S=dict(display_name="Signal Avatar",
                unlocked="You don't need a transmitter anymore. Nine years on, you are the emergency band, and half the towers in Bangkok still tune in without knowing why.",
                playstyle="Full avatar: a single Final Broadcast ends anything already drowning in the noise.",
                cards=[("primary","Avatar's Feedback","Every frequency this city has ever carried, at once."),
                       ("execute","Final Broadcast","No transmitter left to burn out. Just the signal, and the target."),
                       ("aoe","Emergency Frequency","Every tower in range, reached at once, whether they wanted it or not."),
                       ("empower","Boundless Signal","Nothing left to tune. The frequency simply is you now.")]),
         )),
]

def build_rank_classes_and_cards(fam):
    classes = []
    cards = []
    key = fam["key"]
    primary_tag = fam["primary_tag"]
    secondary_tag = fam["secondary_tag"]
    resource_name = fam["resource_name"]
    prev_id = fam["e_id"]
    for i, rank in enumerate(RANK_ORDER):
        rdata = fam["ranks"][rank]
        cid = f"{key}_{rank.lower()}"
        hp = cumulative_hp(fam["e_hp"], fam["hp_tier"], rank)
        resource = RESOURCE_BY_RANK[rank]
        primary_val = v(fam["primary_e"], rank)
        block_val = v(fam["block_e"], rank)
        dot_val = max(2, round(primary_val * 0.6))
        empower_val = max(2, round(primary_val * 0.55))
        aoe_val = max(2, round(primary_val * 0.8))
        execute_val = primary_val

        deck = []
        rank_cards = []
        slot_specs = rdata["cards"]
        for slot, name, desc in slot_specs:
            card_id = f"{key}_{rank.lower()}_{slot}"
            if slot == "primary":
                eff = fam.get("primary_effect", "damage")
                rank_cards.append(card(card_id, name, primary_tag, cid, 1, desc, eff, primary_val))
            elif slot == "secondary" or slot == "secondary2":
                eff = fam.get("secondary_effect", "damage")
                rank_cards.append(card(card_id, name, secondary_tag, cid, 1, desc, eff, primary_val if eff != "block" else block_val))
            elif slot == "dot" or slot == "dot2":
                rank_cards.append(card(card_id, name, primary_tag, cid, 1, desc, "dot", dot_val))
            elif slot == "block" or slot == "block2":
                rank_cards.append(card(card_id, name, "power", cid, 1, desc, "block", block_val))
            elif slot == "empower" or slot == "empower2" or slot == "empower3":
                rank_cards.append(card(card_id, name, "power", cid, 0, desc, "empower_next", empower_val))
            elif slot == "aoe" or slot == "aoe2":
                rank_cards.append(card(card_id, name, primary_tag, cid, 1, desc, "aoe_damage", aoe_val))
            elif slot == "execute":
                rank_cards.append(card(card_id, name, primary_tag, cid, 2, desc, "execute", execute_val))
        cards.extend(rank_cards)
        deck_ids = [c["id"] for c in rank_cards]
        # 5-card deck: double the first (primary) card for combo bias
        deck = [deck_ids[0]] + deck_ids

        evolves_to = [f"{key}_{RANK_ORDER[i+1].lower()}"] if i + 1 < len(RANK_ORDER) else []

        classes.append(dict(
            id=cid, display_name=rdata["display_name"], rank=rank, is_hidden=True,
            locked_description="???", unlocked_description=rdata["unlocked"],
            playstyle=rdata["playstyle"], max_hp=hp, max_resource=resource, resource_name=resource_name,
            deck=deck, evolves_from=prev_id, evolves_to=evolves_to,
            evolution_hint="", unlock_type="hidden_event",
        ))
        prev_id = cid
    return classes, cards

def main():
    with open(f"{REPO}/data/classes.json") as f:
        classes = json.load(f)
    with open(f"{REPO}/data/cards.json") as f:
        cards = json.load(f)

    existing_class_ids = {c["id"] for c in classes}
    existing_card_ids = {c["id"] for c in cards}

    # Wire up evolves_to on each existing E-rank class to point at its D-rank.
    e_to_d = {fam["e_id"]: f"{fam['key']}_d" for fam in FAMILIES}
    for c in classes:
        if c["id"] in e_to_d:
            c["evolves_to"] = [e_to_d[c["id"]]]

    total_new_classes = 0
    total_new_cards = 0
    for fam in FAMILIES:
        new_classes, new_cards = build_rank_classes_and_cards(fam)
        for nc in new_classes:
            assert nc["id"] not in existing_class_ids, f"dup class {nc['id']}"
            existing_class_ids.add(nc["id"])
        for nc in new_cards:
            assert nc["id"] not in existing_card_ids, f"dup card {nc['id']}"
            existing_card_ids.add(nc["id"])
        classes.extend(new_classes)
        cards.extend(new_cards)
        total_new_classes += len(new_classes)
        total_new_cards += len(new_cards)

    class_ids = {c["id"] for c in classes}
    card_ids = {c["id"] for c in cards}
    for c in classes:
        for cid in c["deck"]:
            assert cid in card_ids, f"class {c['id']} deck references missing card {cid}"
        for evo in c["evolves_to"]:
            assert evo in class_ids, f"class {c['id']} evolves_to missing class {evo}"
        if c["evolves_from"]:
            assert c["evolves_from"] in class_ids, f"class {c['id']} evolves_from missing {c['evolves_from']}"
    for c in cards:
        assert c["class_id"] in class_ids, f"card {c['id']} references missing class {c['class_id']}"

    with open(f"{REPO}/data/classes.json", "w") as f:
        json.dump(classes, f, indent=2, ensure_ascii=False)
        f.write("\n")
    with open(f"{REPO}/data/cards.json", "w") as f:
        json.dump(cards, f, indent=2, ensure_ascii=False)
        f.write("\n")

    print(f"families processed: {len(FAMILIES)}")
    print(f"new classes: {total_new_classes}, new cards: {total_new_cards}")
    print(f"classes total: {len(classes)}, cards total: {len(cards)}")

if __name__ == "__main__":
    main()
