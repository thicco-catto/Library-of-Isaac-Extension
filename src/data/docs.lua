---@diagnostic disable: duplicate-doc-alias, undefined-doc-name
_G.TSIL = {}

--- Helper function to benchmark the performance of a function.
--- This function is variadic, which means that you can supply as many functions as you want to
--- benchmark.
---
--- This function uses the `Isaac.GetTime` method to record how long the function took to execute.
--- This method only reports time in milliseconds. For this reason, if you are benchmarking smaller
--- functions, then you should provide a very high value for the number of trials.
---@param numTrials integer
---@vararg function
---@return number[] # A table containing the average time in milliseconds for each function (this will be printed in the log)
function TSIL.Benchmark.Benchmark(numTrials, ...)
end

---Helper function to find out how large a bomb explosion is based on the damage inflicted.
---@param damage number
---@return number
function TSIL.Bombs.GetBombRadiusFromDamage(damage)
end

---Helper function to get all of the bosses in the room.
---@param entityType EntityType? Optional. If specified, will only get the bosses that match the type. Default is -1, which matches every type.
---@param variant integer? Optional. If specified, will only get the bosses that match the variant. Default is -1, which matches every variant.
---@param subType integer? Optional. If specified, will only get the bosses that match the sub-type. Default is -1, which matches every sub-type.
---@param ignoreFriendly boolean? Optional. Default is false
---@return EntityNPC[]
function TSIL.Bosses.GetBosses(entityType, variant, subType, ignoreFriendly)
end

---Helper function to check if the provided NPC is a Sin miniboss, such as Sloth or Lust.
---@param npc EntityNPC
---@return boolean
function TSIL.Bosses.IsSin(npc)
end

---Helper function to spawn a boss.
---
---Use this function instead of `TSIL.Entities.SpawnNPC` since it handles automatically spawning multiple segments
---for multi-segment bosses.
---
---By default, this will spawn Chub (and his variants) with 3 segments, Lokii with 2 copies,
---Gurglings/Turdlings with 2 copies, and other multi-segment bosses with 4 segments. You can
---customize this via the "numSegments" argument.
---@param entityType EntityType
---@param variant integer
---@param subType integer
---@param position Vector 
---@param velocity Vector?
---@param spawner Entity?
---@param seedOrRNG? integer | RNG
---@param numSegments integer?
---@return EntityNPC
function TSIL.Bosses.SpawnBoss(entityType, variant, subType, position, velocity, spawner, seedOrRNG, numSegments)
end

--- Helper function to add a charge to the player's active item. Will flash the HUD and play the
--- appropriate sound effect, depending on whether the charge is partially full or completely full.
---
--- If the player's active item is already fully charged, then this function will return 0 and not
--- flash the hud.
---
--- This function will take the following things into account:
--- - The Battery
--- - AAA Battery
---@param player EntityPlayer The player to grant the charges to.
---@param activeSlot ActiveSlot? Optional. The slot to grant the charges to. Default is `ActiveSlot.SLOT_PRIMARY`.
---@param numCharges integer? Optional. The amount of charges to grant. Default is 1.
---@param playSoundEffect boolean? Optional. Whether to play a charge-related sound effect. Default is true.
---@return integer # The amount of charges that were actually granted. For example, if the active item was only one away from a full charge, but the `numCharges` provided to the function was 2, then this function would return 1.
function TSIL.Charge.AddCharge(player, activeSlot, numCharges, playSoundEffect)
end

--- Helper function to get the amount of charges away from the maximum charge that a particular
--- player is.
---
--- This function accounts for The Battery. For example, if the player has 2/6 charges on a D6, this
--- function will return 10 (because there are 4 charges remaining on the base charge and 6 charges
--- remaining on The Battery charge).
---@param player EntityPlayer The player to get the charges from 
---@param activeSlot ActiveSlot? Optional. The slot to get the charges from. Default is `ActiveSlot.SLOT_PRIMARY`.
---@return integer
function TSIL.Charge.GetChargesAwayFromMax(player, activeSlot)
end

--- Helper function to get the combined normal charge and the battery charge for the player's active
--- item. This is useful because you have to add these two values together when setting the active
--- charge.
---@param player EntityPlayer The player to get the charges from.
---@param activeSlot ActiveSlot? Optional. The slot to get the charges from. Default is `ActiveSlot.SLOT_PRIMARY`
---@return integer
function TSIL.Charge.GetTotalCharge(player, activeSlot)
end

--- Helper function to check if a player's active item is "double charged", meaning that it has both
--- a full normal charge and a full charge from The Battery.
---@param player EntityPlayer The Player to check
---@param activeSlot ActiveSlot? Optional. The slot to check. Default is `ActiveSlot.SLOT_PRIMARY`
---@return boolean
function TSIL.Charge.IsActiveSlotDoubleCharged(player, activeSlot)
end

---Helper function to check if a collectible type has a given flag
---@param collectibleType CollectibleType
---@param flag ItemConfigTag
---@return boolean
function TSIL.Collectibles.CollectibleHasFlag(collectibleType, flag)
end

--- Helper function to check if two collectible sprites are the same.
--- @param sprite1 Sprite
--- @param sprite2 Sprite
--- @return boolean
function TSIL.Collectibles.CollectibleSpriteEquals(sprite1, sprite2)
end

--- Helper function to change the sprite of a collectible pedestal
---@param collectible EntityPickup
---@param spriteSheet string? # Optional. If not set, the sprite will be removed, like if the item had already been taken.
function TSIL.Collectibles.SetCollectibleSprite(collectible, spriteSheet)
end

--- Helper function to get the coin cost a collectible would have if it were being offered as a
--- Devil Room Deal.
--- @param collectibleType CollectibleType
--- @return integer
function TSIL.Collectibles.GetCollectibleDevilCoinPrice(collectibleType)
end

--- Helper function to get the heart cost a collectible would have if it were being offered as a
--- Devil Room Deal.
--- @param collectibleType CollectibleType # If this is set to `COLLECTIBLE_NULL` then it'll return `PRICE_FREE`
--- @param player EntityPlayer
--- @return PickupPrice
function TSIL.Collectibles.GetCollectibleDevilHeartPrice(collectibleType, player)
end

--- Mods may have to keep track of data relating to a collectible. Finding an index for these kinds
--- of data structures is difficult, since collectibles are respawned every time a player re-enters a
--- room (like all other pickups), so the `PtrHash` will change.
---
--- Use this function to get a unique index for a collectible to use in these data structures.
---
--- Collectibles are a special case of pickups: they cannot be pushed around. (They actually can be
--- pushed, but usually will stay on the same grid index.) Thus, it is possible to generate a
--- somewhat reliable non-stateful index for collectibles. We use a 4-tuple of the room list index,
--- the grid index of the collectible in the room, the collectible's `SubType`, and the collectible's
--- `InitSeed`.
---
--- Collectibles that are shifted by Tainted Isaac's mechanic will have unique collectible indexes
--- because the `SubType` is different. (The collectible entities share the same `InitSeed` and
--- `PtrHash`.)
---
--- Collectibles that are rolled (with e.g. a D6) will have unique collectible indexes because the
--- `SubType` and `InitSeed` are different. If you want to track collectibles independently of any
--- rerolls, then you can use the `PtrHash` as an index instead. (The `PtrHash` will not persist
--- between rooms, however.)
---
--- Note that:
--- - The grid index is a necessary part of the collectible index because Diplopia and Crooked Penny
---   can cause two or more collectibles with the same `SubType` and `InitSeed` to exist in the same
---   room.
--- - This index will fail in the case where the player uses Diplopia or a successful Crooked Penny
---   seven or more times in the same room, since that will cause two or more collectibles with the
---   same grid index, `SubType`, and `InitSeed` to exist. (More than seven is required in non-1x1
---   rooms.)
--- - The `SubType` is a necessary part of the collectible index because Tainted Isaac will
---   continuously cause collectibles to morph into new sub-types with the same `InitSeed`.
--- - Using a collectible's position as part of the index is problematic, since players can push a
---   pedestal. (Even using the grid index does not solve this problem, since it is possible in
---   certain cases for collectibles to be spawned at a position that is not aligned with the grid,
---   and the pedestal pushed to an adjacent tile, but this case should be extremely rare.)
--- - Mega Chests spawn two collectibles on the exact same position. However, both of them will have
---   a different `InitSeed`, so this is not a problem for this indexing scheme.
--- - The indexing scheme used is different for collectibles that are inside of a Treasure Room or
---   Boss Room, in order to handle the case of the player seeing the same collectible again in a
---   post-Ascent Treasure Room or Boss Room. A 5-tuple of stage, stage type, grid index, `SubType`,
---   and `InitSeed` is used in this case. (Using the room list index or the room grid index is not
---   suitable for this purpose, since both of these values can change in the post-Ascent rooms.)
---   Even though Treasure Rooms and Boss Rooms are grouped together in this scheme, there probably
---   will not be collectibles with the same grid index, SubType, and InitSeed.
---@param collectible EntityPickup
---@return CollectibleIndex
function TSIL.Collectibles.GetCollectibleIndex(collectible)
end

--- Helper function to get the maximum amount of charges that a collectible has. Returns 0 if the
--- provided collectible type was not valid.
---@param collectibleType CollectibleType
---@return number 
function TSIL.Collectibles.GetCollectibleMaxCharges(collectibleType)
end

--- Returns a list with all items currently loaded.
---
--- Use only inside a callback or not all modded items may be loaded.
--- @return ItemConfig_Item[]
function TSIL.Collectibles.GetCollectibles()
end

--- Returns a list of all items of a certain quality.
---
--- Use only inside a callback or not all modded items may be loaded.
--- @param quality integer
--- | 0
--- | 1
--- | 2
--- | 3
--- | 4
--- @return ItemConfig_Item[]
function TSIL.Collectibles.GetCollectiblesByQuality(quality)
end

--- Returns a list of all vanilla items.
--- @return ItemConfig_Item[]
function TSIL.Collectibles.GetVanillaCollectibles()
end

--- Returns a list of all modded items currently loaded.
--- 
--- Use only inside a callback or not all modded items may be loaded.
--- @return ItemConfig_Item[]
function TSIL.Collectibles.GetModdedCollectibles()
end

--- Returns a list of all items that have all the given tags.
--- 
--- Use only inside a callback or not all modded items may be loaded.
---@param ... ItemConfigTag
---@return ItemConfig_Item[]
function TSIL.Collectibles.GetCollectiblesWithTag(...)
end

--- Returns true if the collectible has a red question mark sprite.
--- 
--- Note that this function will not work properly in a render callback
--- with the render mode set to `RenderMode.WATER_REFLECT`.
--- @param collectible EntityPickup
--- @return boolean
function TSIL.Collectibles.IsBlindCollectible(collectible)
end

--- Returns true if the collectible is a glitched item, like because of the effect of TMTRAINER.
--- @param collectible EntityPickup
--- @return boolean
function TSIL.Collectibles.IsGlitchedCollectible(collectible)
end

--- Returns true if the collectible type corresponds a modded item.
--- @param collectibleType CollectibleType
--- @return boolean
function TSIL.Collectibles.IsModdedColllectible(collectibleType)
end

--- Returns true if the collectible is either `ITEM_PASSIVE` or `ITEM_FAMILIAR`.
--- @param collectibleType CollectibleType
--- @return boolean
function TSIL.Collectibles.IsPassiveCollectible(collectibleType)
end

--- Helper function to set a collectible sprite to a red question mark.
--- @param collectible EntityPickup
function TSIL.Collectibles.SetCollectibleBlind(collectible)
end

--- Helper function to change a collectible into a glitched one.
---@param collectible EntityPickup
function TSIL.Collectibles.SetCollectibleGlitched(collectible)
end

--- Helper function to change the collectible in a pedestal.
---
--- If `COLLECTIBLE_NULL` is given as the new subtype, it'll try removing the item,
--- as if the player had already picked it.
---@param collectible EntityPickup
---@param newSubType CollectibleType
function TSIL.Collectibles.SetCollectibleSubType(collectible, newSubType)
end

--- Empties an item pedestal. If it's a shop item, it removes it completely.
--- @param collectible EntityPickup
--- @return boolean
function TSIL.Collectibles.TryRemoveCollectible(collectible)
end

---Copies a color
---@param color Color
---@return Color
function TSIL.Color.CopyColor(color)
end

---Gets a random color.
---@param seedOrRNG? integer | RNG Optional. The `Seed` or `RNG` object to use. If an `RNG` object is provided, the `RNG:Next` method will be called. Default is `TSIL.RNG.GetRandomSeed()`
---@param alpha number? Optional. The alpha value to use. Default is 1.
---@return Color
function TSIL.Color.GetRandomColor(seedOrRNG, alpha)
end

---Converts a hex string like "#33aa33" to a Color object.
---@param hex string
---@param alpha number
---@return Color
function TSIL.Color.HexToColor(hex, alpha)
end

---Converts a hex string like "#33aa33" to a KColor object.
---@param hex string
---@param alpha number
---@return KColor
function TSIL.Color.HexToKColor(hex, alpha)
end

--- Registers a function to be called by a custom TSIL callback.
--- 
--- Functions with higher priority will be caller earlier.
--- @param mod table
--- @param callback CustomCallback
--- @param funct function
--- @param priority integer | CallbackPriority
--- @param ... integer
function TSIL.AddCustomCallback(mod, callback, funct, priority, ...)
end

--- Registers a function to be triggered by a vanilla callback.
--- 
--- Using this function allows you to use the built-in priority system.
--- @param mod table
--- @param callback ModCallbacks
--- @param funct function
--- @param priority CallbackPriority | integer
--- @param optionalParam? integer
function TSIL.AddVanillaCallback(mod, callback, funct, priority, optionalParam)
end

--- @param id string
--- @param callback ModCallbacks
--- @param funct function
--- @param priority integer | CallbackPriority
--- @param optionalParam? integer
function TSIL.__AddInternalVanillaCallback(id, callback, funct, priority, optionalParam)
end

--- @param id string
--- @param callback CustomCallback
--- @param funct function
--- @param priority integer | CallbackPriority
--- @param ... integer
function TSIL.__AddInternalCustomCallback(id, callback, funct, priority, ...)
end

--- @enum OptionalArgCheckType
local OptionalArgCheckType = {
	NONE = 0,
	ITSELF = 1,
	TYPE = 2,
	VARIANT = 3,
	SUBTYPE = 4,
	PLAYER_TYPE = 5,
	SECOND_ARG = 6
}

--- @enum ReturnType
local ReturnType = {
	NONE = 0,
	SKIP_NEXT = 1,
	LAST_WINS = 2,
	NEXT_ARGUMENT = 3
}

--- @param mod table
--- @param callback CustomCallback
--- @param funct function
function TSIL.RemoveCustomCallback(mod, callback, funct)
end

--- @param mod table
--- @param callback ModCallbacks
--- @param funct function
function TSIL.RemoveVanillaCallback(mod, callback, funct)
end

---Helper function to get the current time for benchmarking / profiling purposes.
---
---The return value will either be in seconds or milliseconds, depending on if the "--luadebug" flag
---is turned on or not.
---
---If the "--luadebug" flag is present, then this function will use the `socket.gettime` method,
---which returns the epoch timestamp in seconds (e.g. "1640320492.5779"). This is preferable over
---the more conventional `Isaac.GetTime` method, since it has one extra decimal point of precision.
---
---If the "--luadebug" flag is not present, then this function will use the `Isaac.GetTime` method,
---which returns the number of milliseconds since the computer's operating system was started (e.g.
---"739454963").
---@return number
function TSIL.Debug.GetTime()
end

---Helper function to get a stack trace.
---
---This will only work if the `--luadebug` launch option is enabled.
---@return string
function TSIL.Debug.GetTraceback()
end

---Players can boot the game with an launch option called "--luadebug", which will enable additional
---functionality that is considered to be unsafe. For more information about this flag, see the
---wiki: https://bindingofisaacrebirth.fandom.com/wiki/Launch_Options
---
---When this flag is enabled, the global environment will be slightly different. The differences are
---documented here: https://wofsauge.github.io/IsaacDocs/rep/Globals.html
---
---This function uses the `package` global variable as a proxy to determine if the "--luadebug" flag
---is enabled or not.
---@return boolean
function TSIL.Debug.IsLuaDebugEnabled()
end

---Helper function to print a stack trace to the "log.txt" file, similar to JavaScript's
---`console.trace` function.
---This will only work if the `--luadebug` launch option is enabled
function TSIL.Debug.Traceback()
end

--- Helper function to get the current dimension.
---@return Dimension @ If something fails, `Dimension.CURRENT` will be returned
function TSIL.Dimensions.GetDimension()
end

--- Helper function to check if the players are in a given dimension.
---@param dimension Dimension
---@return boolean
function TSIL.Dimensions.InDimension(dimension)
end

--- Helper function to convert a given amount of angle degrees into the corresponding `Direction` enum.
---@param angleDegrees number
---@return Direction
function TSIL.Direction.AngleToDirection(angleDegrees)
end

--- Helper function to get the corresponding angle degrees from a `Direction` enum.
---@param direction Direction
---@return integer
function TSIL.Direction.DirectionToDegrees(direction)
end

--- Helper function to get a Vector pointing in a given Direction.
---@param direction Direction
---@return Vector
function TSIL.Direction.DirectionToVector(direction)
end

--- Helper function to open a door instantly without playing its open animation.
---@param door GridEntityDoor
function TSIL.Doors.CloseDoorFast(door)
end

--- Helper funciton to close all doors in the current room.
---@param playAnim boolean @ If set to false, the doors won't play the close animation.
function TSIL.Doors.CloseAllDoors(playAnim)
end

--- Helper function to reset an unlocked door back to its locked state.
---@param door GridEntityDoor
function TSIL.Doors.LockDoor(door)
end

--- Helper function to get a door slot flag from a door slot.
---@param doorSlot DoorSlot
---@return integer
function TSIL.Doors.DoorSlotToDoorSlotFlag(doorSlot)
end

--- Helper function to convert the provided door slots into a door slot bitmask.
---@param ... DoorSlot
---@return integer
function TSIL.Doors.DoorSlotsToDoorSlotBitMask(...)
end

--- Helper function to get the door slots corresponding to a door slot bit mask.
---@param doorSlotBitMask integer
---@return DoorSlot[]
function TSIL.Doors.GetDoorSlotsFromDoorSlotBitMask(doorSlotBitMask)
end

--- Helper function to get the direction corresponding to a given door slot.
---@param doorSlot DoorSlot
---@return Direction
function TSIL.Doors.DoorSlotToDirection(doorSlot)
end

--- Helper function to get the offset from a door position that a player will enter a room at.
---@param doorSlot any
---@return Vector
function TSIL.Doors.GetDoorSlotEnterPositionOffset(doorSlot)
end

--- Helper function to get the position that a player will enter a room at corresponding to a door slot.
---@param doorSlot DoorSlot
---@return Vector
function TSIL.Doors.GetDoorSlotEnterPosition(doorSlot)
end

--- Helper function to get the position that a player will enter a room at corresponding to a door.
---@param door GridEntityDoor
---@return Vector
function TSIL.Doors.GetDoorEnterPosition(door)
end

--- Helper function to return all doors in the current room.
---
--- You can optionally specify one or more room types to return only the doors
--- that match the specified room types.
---@param ... RoomType
---@return GridEntityDoor[]
function TSIL.Doors.GetDoors(...)
end

--- Helper function to return all doors in the current room that lead to
--- a given room index.
---@param ... integer
---@return GridEntityDoor[]
function TSIL.Doors.GetDoorsToRoomIndex(...)
end

--- Helper function to get all the possible door slots in a room shape.
---@param roomShape RoomShape
---@return DoorSlot[]
function TSIL.Doors.GetDoorSlotsForRoomShape(roomShape)
end

--- Helper function to get the corresponding door slot for a given room shape and grid coordinates.
---@param roomShape RoomShape
---@param x integer
---@param y integer
---@return DoorSlot?
function TSIL.Doors.GetRoomShapeDoorSlot(roomShape, x, y)
end

--- Helper function to get the grid coordinates for a specific room shape and door slot combination.
---@param roomShape RoomShape
---@param doorSlot DoorSlot
---@return {x:integer, y:integer}?
function TSIL.Doors.GetRoomShapeDoorSlotCoordinates(roomShape, doorSlot)
end

--- Helper function to get the angel room door in the current room.
--- If there isn't any, returns nil.
---@return GridEntityDoor?
function TSIL.Doors.GetAngelRoomDoor()
end

--- Helper function to get the devil room door in the current room.
--- If there isn't any, returns nil.
---@return GridEntityDoor?
function TSIL.Doors.GetDevilRoomDoor()
end

--- Helper function to get an angel or devil room door in the current room.
---
--- Note that if there are both an angel and devil room door it'll only return the one in the lowest door slot.
---@return GridEntityDoor?
function TSIL.Doors.GetAngelOrDevilRoomDoor()
end

--- Helper function to get the door that leads to the blue womb entrance in the current room.
---@return GridEntityDoor?
function TSIL.Doors.GetBlueWombDoor()
end

--- Helper function to get the door that leads to a repentance secret exit in the current room.
---@return GridEntityDoor?
function TSIL.Doors.GetSecretExitDoor()
end

--- Helper function to check if a given door slot can be present in a given room shape.
---@param doorSlot DoorSlot
---@param roomShape RoomShape
---@return boolean
function TSIL.Doors.IsDoorSlotInRoomShape(doorSlot, roomShape)
end

--- Helper function to see if a door leads to an angel deal room.
---@param door GridEntityDoor
---@return boolean
function TSIL.Doors.IsAngelRoomDoor(door)
end

--- Helper function to see if a door leads to an devil deal room.
---@param door GridEntityDoor
---@return boolean
function TSIL.Doors.IsDevilRoomDoor(door)
end

--- Helper function to see if a door is the blue womb entrance door that
--- appears after defeating Mom's Heart/It Lives.
---@param door GridEntityDoor
---@return boolean
function TSIL.Doors.IsBlueWombDoor(door)
end

--- Helper function to see if a door leads to any of the secret exit introduced
--- in Repentance, that lead you to the Repentance floors.
---@param door GridEntityDoor
---@return boolean
function TSIL.Doors.IsSecretExitDoor(door)
end

--- Helper function to see if a door leads to the secret exit to Downpour.
---@param door GridEntityDoor
---@return boolean
function TSIL.Doors.IsDoorToDownpour(door)
end

--- Helper function to see if a door leads to the secret exit to Mausoleum.
---@param door GridEntityDoor
---@return boolean
function TSIL.Doors.IsDoorToMausoleum(door)
end

--- Helper function to see if a door leads to the secret exit to the ascent version of Mausoleum,
--- located in Depths 2 and requires The Polaroid or The Negative to open.
---@param door GridEntityDoor
---@return boolean
function TSIL.Doors.IsDoorToMausoleumAscent(door)
end

--- Helper function to see if a door leads to the secret exit to Mines.
---@param door GridEntityDoor
---@return boolean
function TSIL.Doors.IsDoorToMines(door)
end

--- Helper function to see if a door is the door that spawns after defeating Mom in
--- Mausoleum II and requires both knife pieces to open.
---@param door GridEntityDoor
---@return boolean
function TSIL.Doors.IsDoorToMomsHeart(door)
end

--- Helper function to check if a door is a hole in the wall that appears after
--- bombing the entrance to a secret room.
---
--- Note that the door still exists even if it hasn't been bombed yet.
---@param door GridEntityDoor
---@return boolean
function TSIL.Doors.IsSecretRoomDoor(door)
end

--- Helper function to check if a door is a hole in the wall that appears after
--- bombing the entrance to a secret room but hasn't been revealed yet.
---@param door GridEntityDoor
---@return boolean
function TSIL.Doors.IsHiddenSecretDoor(door)
end

--- Helper function to open a door instantly without playing its open animation.
---@param door GridEntityDoor
function TSIL.Doors.OpenDoorFast(door)
end

--- Helper funciton to open all doors in the current room
---@param playAnim boolean @ If set to false, the doors won't play the open animation.
function TSIL.Doors.OpenAllDoors(playAnim)
end

--- Helper function to remove a single door
---@param door GridEntityDoor
function TSIL.Doors.RemoveDoor(door)
end

--- Helper function to remove all the given doors
---@param doors GridEntityDoor[]
function TSIL.Doors.RemoveDoors(doors)
end

--- Helper function to remove all doors of the given room types.
---@param ... RoomType @ If no room type is specified, all doors will get removed.
function TSIL.Doors.RemoveAllDoorsOfType(...)
end

--- Helper function to get all unused door slots in the current room.
---
--- Useful to spawn custom doors.
---@return DoorSlot[]
function TSIL.Doors.GetUnusedDoorSlots()
end

--- Helper function to check if the current room has any unused door slots.
---@return boolean
function TSIL.Doors.HasUnusedDoorSlot()
end

--- Helper function to get all of the entities in the room or all of the entities tht match a specific entity type / variant / sub-type.
--- Due to bugs with `Isaac.FindInRadius`, this function uses `Isaac.GetRoomEntities`, which is more expensive but is also more robust.
--- (If a matching entity type is provided, then `Isaac.FindByType` will be used instead.)
--- @param entityType EntityType|integer? Optional. If specified, will only get the entities that match the type. Default is -1, which matches every type.
--- @param variant integer? Optional. If specified, will only get the entities that match the variant. Default is -1, which matches every variant.
--- @param subType integer? Optional. If specified, will only get the entities that match the sub-type. Default is -1, which matches every sub-type.
--- @param ignoreFriendly boolean? Optional. If set to true, it will exclude friendly NPCs from being returned. Default is false. Will only be taken into account if the `entityType` is specified.
--- @return Entity[]
function TSIL.Entities.GetEntities(entityType, variant, subType, ignoreFriendly)
end

--- Helper function to get a map containing the positions of every entity in the current room.
--- @param entities Entity[] @Optional. If provided, will only get the positions of the given entities, instead of calling `Isaac.GetRoomEntities`.
--- @return table<EntityPtr, Vector>
function TSIL.Entities.GetEntityPositions(entities)
end

--- Helper function to get a map containing the velocities of every entity in the current room.
--- @param entities Entity[] @Optional. If provided, will only get the velocities of the given entities, instead of calling `Isaac.GetRoomEntities`.
--- @return table<EntityPtr, Vector>
function TSIL.Entities.GetEntityVelocities(entities)
end

--- Helper function to set the positions of all the entities in the room.
--- 
--- Useful for rewinding entity positions.
--- @param positions table<EntityPtr, Vector>
--- @param entities Entity[] @Optional If provided, will only set the positions of the given entities, instead of calling `Isaac.GetRoomEntities`.
function TSIL.Entities.SetEntityPositions(positions, entities)
end

--- Helper function to set the velocities of all the entities in the room.
--- 
--- Useful for rewinding entity velocities.
--- @param velocities table<EntityPtr, Vector>
--- @param entities Entity[] @Optional If provided, will only set the velocities of the given entities, instead of calling `Isaac.GetRoomEntities`.
function TSIL.Entities.SetEntityVelocities(velocities, entities)
end

--- Checks if an entity is colliding with a grid entity.
--- If it does, returns the grid entity it's colliding with, else returns nil.
--- @param entity Entity
--- @return GridEntity?
function TSIL.Entities.IsCollidingWithGrid(entity)
end

---Helper function to spawn an entity. Use this instead of the `Isaac.Spawn` method if you do not
---need to specify the velocity or spawner.
---@param entityType EntityType
---@param variant integer 
---@param subType integer
---@param position Vector
---@param velocity Vector?
---@param spawner Entity?
---@param seedOrRNG integer | RNG?
---@return Entity
function TSIL.Entities.Spawn(entityType, variant, subType, position, velocity, spawner, seedOrRNG)
end

--- Helper function to get all of the bombs in the room. (Specifically, this refers to the `EntityBomb` class, not bomb pickups.)
--- @param bombVariant BombVariant|integer? Optional. Default is -1, which matches all variants.
--- @param subType integer? Optional. Default is -1, which matches all sub-types.
--- @return EntityBomb[]
function TSIL.EntitySpecific.GetBombs(bombVariant, subType)
end

--- Helper function to get all of the effects in the room.
--- @param effectVariant EffectVariant|integer? Optional. Default is -1, which matches all variants.
--- @param subType integer? Optional. Default is -1, which matches all sub-types.
--- @return EntityEffect[]
function TSIL.EntitySpecific.GetEffects(effectVariant, subType)
end

--- Helper function to get all of the familiars in the room.
--- @param familiarVariant FamiliarVariant|integer? Optional. Default is -1, which matches all variants.
--- @param subType integer? Optional. Default is -1, which matches all sub-types.
--- @return EntityFamiliar[]
function TSIL.EntitySpecific.GetFamiliars(familiarVariant, subType)
end

--- Helper function to get all of the knives in the room.
--- @param knifeVariant KnifeVariant|integer? Optional. Default is -1, which matches all variants.
--- @param subType integer? Optional. Default is -1, which matches all sub-types.
function TSIL.EntitySpecific.GetKnives(knifeVariant, subType)
end

--- Helper function to get all of the lasers in the room.
--- @param laserVariant LaserVariant|integer? Optional. Default is -1, which matches all variants.
--- @param subType integer? Optional. Default is -1, which matches all sub-types.
--- @return EntityLaser[]
function TSIL.EntitySpecific.GetLasers(laserVariant, subType)
end

--- Helper function to get all of the NPCs in the room.
--- @param entityType EntityType|integer? Optional. Default is -1, which matches all types.
--- @param variant integer? Optional. Default is -1, which matches all variants.
--- @param subType integer? Optional. Default is -1, which matches all sub-types.
--- @param ignoreFriendly boolean? Optional. If set to true, it will exclude friendly NPCs from being returned. Default is false. Will only be taken into account if the `entityType` is specified.
--- @return EntityNPC[]
function TSIL.EntitySpecific.GetNPCs(entityType, variant, subType, ignoreFriendly)
end

--- Helper function to get all of the pickups in the room.
--- @param pickupVariant PickupVariant|integer? Optional. Default is -1, which matches all variants.
--- @param subType integer? Optional. Default is -1, which matches all sub-types.
--- @return EntityPickup[]
function TSIL.EntitySpecific.GetPickups(pickupVariant, subType)
end

--- Helper function to get all of the projectiles in the room.
--- @param projectileVariant ProjectileVariant|integer? Optional. Default is -1, which matches all variants.
--- @param subType integer? Optional. Default is -1, which matches all sub-types.
--- @return EntityProjectile[]
function TSIL.EntitySpecific.GetProjectiles(projectileVariant, subType)
end

--- Helper function to get all of the slots in the room.
--- @param slotVariant SlotVariant|integer? Optional. Default is -1, which matches all variants.
--- @param subType integer? Optional. Default is -1, which matches all sub-types.
--- @return Entity[]
function TSIL.EntitySpecific.GetSlots(slotVariant, subType)
end

--- Helper function to get all of the tears in the room.
--- @param tearVariant TearVariant|integer? Optional. Default is -1, which matches all variants.
--- @param subType integer? Optional. Default is -1, which matches all sub-types.
--- @return EntityTear[]
function TSIL.EntitySpecific.GetTears(tearVariant, subType)
end

---Helper function to spawn an NPC.
---
---Note that if you pass a non-NPC `EntityType` to this function, it will cause a run-time error,
---since the `Entity.ToNPC` method will return nil.
---@param entityType EntityType
---@param variant integer
---@param subType integer
---@param position Vector
---@param velocity Vector?
---@param spawner? Entity
---@param seedOrRNG? integer | RNG
---@return EntityNPC
function TSIL.EntitySpecific.SpawnNPC(entityType, variant, subType, position, velocity, spawner, seedOrRNG)
end

---Helper function to spawn a bomb.
---@param bombVariant BombVariant
---@param subType integer
---@param position Vector
---@param velocity Vector?
---@param spawner Entity?
---@param seedOrRNG integer | RNG?
---@return EntityBomb
function TSIL.EntitySpecific.SpawnBomb(bombVariant, subType, position, velocity, spawner, seedOrRNG)
end

---Helper function to spawn an effect.
---@param effectVariant EffectVariant
---@param subType integer
---@param position Vector
---@param velocity Vector?
---@param spawner Entity
---@param seedOrRNG integer | RNG?
---@return EntityEffect
function TSIL.EntitySpecific.SpawnEffect(effectVariant, subType, position, velocity, spawner, seedOrRNG)
end

---Helper function to spawn a familiar.
---@param familiarVariant FamiliarVariant
---@param subType integer
---@param position Vector
---@param velocity Vector?
---@param spawner Entity
---@param seedOrRNG integer | RNG?
---@return EntityFamiliar
function TSIL.EntitySpecific.SpawnFamiliar(familiarVariant, subType, position, velocity, spawner, seedOrRNG)
end

---Helper function to spawn a knife.
---@param knifeVariant KnifeVariant
---@param subType integer
---@param position Vector
---@param velocity Vector?
---@param spawner Entity
---@param seedOrRNG integer | RNG?
---@return EntityKnife
function TSIL.EntitySpecific.SpawnKnife(knifeVariant, subType, position, velocity, spawner, seedOrRNG)
end

---Helper function to spawn a laser.
---@param laserVariant LaserVariant
---@param subType integer
---@param position Vector
---@param velocity Vector?
---@param spawner Entity
---@param seedOrRNG integer | RNG?
---@return EntityLaser
function TSIL.EntitySpecific.SpawnLaser(laserVariant, subType, position, velocity, spawner, seedOrRNG)
end

---Helper function to spawn a pickup.
---@param pickupVariant PickupVariant
---@param subType integer
---@param position Vector
---@param velocity Vector?
---@param spawner Entity?
---@param seedOrRNG integer | RNG?
---@return EntityPickup
function TSIL.EntitySpecific.SpawnPickup(pickupVariant, subType, position, velocity, spawner, seedOrRNG)
end

---Helper function to spawn a projectile.
---@param projectileVariant ProjectileVariant
---@param subType integer
---@param position Vector
---@param velocity Vector?
---@param spawner Entity
---@param seedOrRNG integer | RNG?
---@return EntityProjectile
function TSIL.EntitySpecific.SpawnProjectile(projectileVariant, subType, position, velocity, spawner, seedOrRNG)
end

---Helper function to spawn a slot.
---@param slotVariant SlotVariant
---@param subType integer
---@param position Vector
---@param velocity Vector?
---@param spawner Entity
---@param seedOrRNG integer | RNG?
---@return Entity
function TSIL.EntitySpecific.SpawnSlot(slotVariant, subType, position, velocity, spawner, seedOrRNG)
end

---Helper function to spawn a tear.
---@param tearVariant TearVariant
---@param subType integer
---@param position Vector
---@param velocity Vector?
---@param spawner Entity
---@param seedOrRNG integer | RNG
---@return EntityTear
function TSIL.EntitySpecific.SpawnTear(tearVariant, subType, position, velocity, spawner, seedOrRNG)
end

--- @enum CallbackPriority
TSIL.Enums.CallbackPriority = {
	LOW = 10,
	MEDIUM = 50,
	HIGH = 100,
	VERY_HIGH = 1000
}

--- @enum CustomCallback
TSIL.Enums.CustomCallback = {
	POST_SLOT_INIT = "POST_SLOT_INIT",
	POST_SLOT_UPDATE = "POST_SLOT_UPDATE",
	POST_SLOT_PRIZE = "POST_SLOT_PRIZE",
	PRE_SLOT_COLLISION = "PRE_SLOT_COLLISION",

	POST_PLAYER_COLLECTIBLE_ADDED = "POST_PLAYER_COLLECTIBLE_ADDED",
	POST_PLAYER_COLLECTIBLE_REMOVED = "POST_PLAYER_COLLECTIBLE_REMOVED",

	POST_PLAYER_GULPED_TRINKET_ADDED = "POST_PLAYER_GULPED_TRINKET_ADDED",
	POST_PLAYER_GULPED_TRINKET_REMOVED = "POST_PLAYER_GULPED_TRINKET_REMOVED",

	POST_GRID_ENTITY_INIT = "POST_GRID_ENTITY_INIT",
	POST_GRID_ENTITY_UPDATE = "POST_GRID_ENTITY_UPDATE",
	POST_GRID_COLLISION = "POST_GRID_COLLISION"
}

---@enum Dimension
TSIL.Enums.Dimension = {
    CURRENT = -1,
    MAIN = 0,
    SECONDARY = 1,
    DEATH_CERTIFICATE = 2
}

--- @enum LockState
TSIL.Enums.LockState = {
    LOCKED = 0,
    UNLOCKED = 1,
}

--- @enum PoopState
TSIL.Enums.PoopState = {
    UNDAMAGED = 0,
    ONE_QUARTER_DAMAGED = 250,
    TWO_QUARTERS_DAMAGED = 500,
    THREE_QUARTERS_DAMAGED = 750,
    DESTROYED = 1000
}

--- @enum RockState
TSIL.Enums.RockState = {
    UNBROKEN = 1,
    BROKEN = 2,
    EXPLODING = 3,
    HALF_BROKEN = 4
}

--- @enum SpiderWebState
TSIL.Enums.SpiderWebState = {
    UNBROKEN = 0,
    BROKEN = 1,
}

--- @enum TNTState
TSIL.Enums.TNTState = {
    UNDAMAGED = 0,
    ONE_QUARTER_DAMAGED = 1,
    TWO_QUARTERS_DAMAGED = 2,
    THREE_QUARTERS_DAMAGED = 3,
    EXPLODED = 4
}

--- @enum CrawlSpaceVariant
TSIL.Enums.CrawlSpaceVariant = {
	NORMAL = 0,
	GREAT_GIDEON = 1,
	SECRET_SHOP = 2,
	PASSAGE_TO_BEGGINING_OF_FLOOR = 3,
	NULL = 4
}

--- @enum PitVariant
TSIL.Enums.PitVariant = {
	NORMAL = 0,
	FISSURE_SPAWNER = 16
}

--- @enum PoopGridEntityVariant
TSIL.Enums.PoopGridEntityVariant = {
	NORMAL = 0,
	RED = 1,
	CORN = 2,
	GOLDEN = 3,
	RAINBOW = 4,
	BLACK = 5,
	WHITE = 6,
	GIGA_TOP_LEFT = 7,
	GIGA_TOP_RIGHT = 8,
	GIGA_BOTTOM_LEFT = 9,
	GIGA_BOTTOM_RIGHT = 10,
	CHARMING = 11
}

--- @enum PressurePlateVariant
TSIL.Enums.PressurePlateVariant = {
	PRESSURE_PLATE = 0,
	REWARD_PLATE = 1,
	GREED_PLATE = 2,
	RAIL_PLATE = 3,
	KILL_ALL_ENEMIES_PLATE = 9,
	SPAWN_ROCKS_PLATE = 10
}

--- @enum RockVariant
TSIL.Enums.RockVariant = {
	NORMAL = 0,
	EVENT = 1
}

--- @enum StatueVariant
TSIL.Enums.StatueVariant = {
	DEVIL = 0,
	ANGEL = 1
}

--- @enum TrapdoorVariant
TSIL.Enums.TrapdoorVariant = {
	NORMAL = 0,
	VOID_PORTAL = 1
}

--- @enum GridEntityXMLType
TSIL.Enums.GridEntityXMLType = {
	DECORATION = 0,
	ROCK = 1000,
	ROCK_BOMB = 1001,
	ROCK_ALT = 1002,
	ROCK_TINTED = 1003,
	ROCK_ALT_2 = 1008,
	ROCK_EVENT = 1009,
	ROCK_SPIKED = 1010,
	ROCK_GOLD = 1011,
	TNT = 1300,
	FIREPLACE = 1400,
	RED_FIREPLACE = 1410,
	POOP_RED = 1490,
	POOP_RAINBOW = 1494,
	POOP_CORN = 1495,
	POOP_GOLDEN = 1496,
	POOP_BLACK = 1497,
	POOP_WHITE = 1498,
	POOP_GIGA = 1499,
	POOP = 1500,
	POOP_CHARMING = 1501,
	BLOCK = 1900,
	PILLAR = 1901,
	SPIKES = 1930,
	SPIKES_ON_OFF = 1931,
	SPIDER_WEB = 1940,
	WALL = 1999,
	PIT = 3000,
	FISSURE_SPAWNER = 3001,
	PIT_EVENT = 3009,
	LOCK = 4000,
	PRESSURE_PLATE = 4500,
	STATUE_DEVIL = 5000,
	STATUE_ANGEL = 5001,
	TELEPORTER = 6100,
	TRAPDOOR = 9000,
	CRAWL_SPACE = 9100,
	GRAVITY = 10000
}

--- @enum InventoryType
TSIL.Enums.InventoryType = {
	COLLECTIBLE = 1,
	TRINKET = 2
}

---@enum ItemConfigTag
TSIL.Enums.ItemConfigTag = {
  --[[
    Dead things (for the Parasite unlock).
   
    Equal to "dead" in "items_metadata.xml".
   
    1 << 0 (1)
   --]]
   DEAD = 1 << 0,

   --[[
     Syringes (for Little Baggy and the Spun transformation).
    
     Equal to "syringe" in "items_metadata.xml".
    
     1 << 1 (2)
    --]]
   SYRINGE = 1 << 1,
 
   --[[
     Mom's things (for Mom's Contact and the Yes Mother transformation).
    
     Equal to "mom" in "items_metadata.xml".
    
     1 << 2 (4)
    --]]
   MOM = 1 << 2,
 
   --[[
     Technology items (for the Technology Zero unlock).
    
     Equal to "tech" in "items_metadata.xml".
    
     1 << 3 (8)
    --]]
   TECH = 1 << 3,
 
   --[[
     Battery items (for the Jumper Cables unlock).
    
     Equal to "battery" in "items_metadata.xml".
    
     1 << 4 (16)
    --]]
   BATTERY = 1 << 4,
 
   --[[
     Guppy items (Guppy transformation).
    
     Equal to "guppy" in "items_metadata.xml".
    
     1 << 5 (32)
    --]]
   GUPPY = 1 << 5,
 
   --[[
     Fly items (Beelzebub transformation).
    
     Equal to "fly" in "items_metadata.xml".
    
     1 << 6 (64)
    --]]
   FLY = 1 << 6,
 
   --[[
     Bob items (Bob transformation).
    
     Equal to "bob" in "items_metadata.xml".
    
     1 << 7 (128)
    --]]
   BOB = 1 << 7,
 
   --[[
     Mushroom items (Fun Guy transformation).
    
     Equal to "mushroom" in "items_metadata.xml".
    
     1 << 8 (256)
    --]]
   MUSHROOM = 1 << 8,
 
    --[[
     Baby items (Conjoined transformation).
    
     Equal to "mushroom" in "items_metadata.xml".
    
     1 << 9 (512)
    --]]
   BABY = 1 << 9,
 
    --[[
     Angel items (Seraphim transformation).
    
     Equal to "angel" in "items_metadata.xml".
    
     1 << 10 (1024)
    --]]
   ANGEL = 1 << 10,
 
    --[[
     Devil items (Leviathan transformation).
    
     Equal to "devil" in "items_metadata.xml".
    
     1 << 11 (2048)
    --]]
   DEVIL = 1 << 11,
 
    --[[
     Poop items (Oh Shit transformation).
    
     Equal to "poop" in "items_metadata.xml".
    
     1 << 12 (4096)
    --]]
   POOP = 1 << 12,
 
    --[[
     Book items (Book Worm transformation).
    
     Equal to "book" in "items_metadata.xml".
    
     1 << 13 (8192)
    --]]
   BOOK = 1 << 13,
 
    --[[
     Spider items (Spider Baby transformation).
    
     Equal to "spider" in "items_metadata.xml".
    
     1 << 14 (16384)
    --]]
   SPIDER = 1 << 14,
 
    --[[
     Quest item (cannot be rerolled or randomly obtained).
    
     Equal to "quest" in "items_metadata.xml".
    
     1 << 15 (32768)
    --]]
   QUEST = 1 << 15,
 
    --[[
     Can be spawned by Monster Manual.
    
     Equal to "monstermanual" in "items_metadata.xml".
    
     1 << 16 (65536)
    --]]
   MONSTER_MANUAL = 1 << 16,
 
    --[[
     Cannot appear in Greed Mode.
    
     Equal to "nogreed" in "items_metadata.xml".
    
     1 << 17 (131072)
    --]]
   NO_GREED = 1 << 17,
 
    --[[
     Food item (for Binge Eater).
    
     Equal to "food" in "items_metadata.xml".
    
     1 << 18 (262144)
    --]]
   FOOD = 1 << 18,
 
    --[[
     Tears up item (for Lachryphagy unlock detection).
    
     Equal to "tearsup" in "items_metadata.xml".
    
     1 << 19 (524288)
    --]]
   TEARS_UP = 1 << 19,
 
    --[[
     Whitelisted item for Tainted Lost.
    
     Equal to "offensive" in "items_metadata.xml".
    
     1 << 20 (1048576)
    --]]
   OFFENSIVE = 1 << 20,
 
    --[[
     Blacklisted item for Keeper & Tainted Keeper.
    
     Equal to "nokeeper" in "items_metadata.xml".
    
     1 << 21 (2097152)
    --]]
   NO_KEEPER = 1 << 21,
 
    --[[
     Blacklisted item for The Lost's Birthright.
    
     Equal to "nolostbr" in "items_metadata.xml".
    
     1 << 22 (4194304)
    --]]
   NO_LOST_BR = 1 << 22,
 
    --[[
     Star themed items (for the Planetarium unlock).
    
     Equal to "stars" in "items_metadata.xml".
    
     1 << 23 (8388608)
    --]]
   STARS = 1 << 23,
 
    --[[
     Summonable items (for Tainted Bethany).
    
     Equal to "summonable" in "items_metadata.xml".
    
     1 << 24 (16777216)
    --]]
   SUMMONABLE = 1 << 24,
 
    --[[
     Can't be obtained in Cantripped challenge.
    
     Equal to "nocantrip" in "items_metadata.xml".
    
     1 << 25 (33554432)
    --]]
   NO_CANTRIP = 1 << 25,
 
    --[[
     Active items that have wisps attached to them (automatically set).
    
     Not equal to any particular tag in "items_metadata.xml". Instead, this is set for all of the
     items in the "wisps.xml" file.
    
     1 << 26 (67108864)
    --]]
   WISP = 1 << 26,
 
    --[[
     Unique familiars that cannot be duplicated.
    
     Equal to "uniquefamiliar" in "items_metadata.xml".
    
     1 << 27 (134217728)
    --]]
   UNIQUE_FAMILIAR = 1 << 27,
 
    --[[
     Items that should not be obtainable in challenges.
    
     Equal to "nochallenge" in "items_metadata.xml".
    
     1 << 28 (268435456)
    --]]
   NO_CHALLENGE = 1 << 28,
 
    --[[
     Items that should not be obtainable in daily runs.
    
     Equal to "nodaily" in "items_metadata.xml".
    
     1 << 29 (536870912)
    --]]
   NO_DAILY = 1 << 29,
 
    --[[
     Items that should be shared between Tainted Lazarus' forms.
    
     This is different from `LAZ_SHARED_GLOBAL` in that it does apply stat changes from the item for
     both characters.
    
     Equal to "lazarusshared" in "items_metadata.xml".
    
     1 << 30 (1073741824)
    --]]
   LAZ_SHARED = 1 << 30,
 
    --[[
     Items that should be shared between Tainted Lazarus' forms but only through global checks (such
     as `PlayerManager = =HasCollectible`).
    
     This is different from `LAZ_SHARED` in that it does not apply stat changes from the item for
     both characters.
    
     Equal to "lazarussharedglobal" in "items_metadata.xml".
    
     1 << 31 (2147483648)
    --]]
   LAZ_SHARED_GLOBAL = 1 << 31,
 
    --[[
     Items that will not be a random starting item for Eden and Tainted Eden.
    
     Equal to "noeden" in "items_metadata.xml".
    
     1 << 32 (4294967296)
    --]]
   NO_EDEN = 1 << 32,
}

---@enum PillEffectType
TSIL.Enums.PillEffectType = {
    NULL = -1,
    POSITIVE = 0,
    NEGATIVE = 1,
    NEUTRAL = 2,
    MODDED = 3
}

---@enum ShockwaveSoundMode
TSIL.Enums.ShockwaveSoundMode = {
    NO_SOUND = 0,
    ON_CREATE = 1,
    LOOP = 2
}

---@enum BlueFlySubType
-- For `EntityType.FAMILIAR` (3), `FamiliarVariant.BLUE_FLY` (43). 
TSIL.Enums.BlueFlySubType = {
  -- A standard fly, like what you get from using Guppy's Head. 
  BLUE_FLY = 0,

  -- Red (explosive) 
  WRATH = 1,

  -- Green (poison) 
  PESTILENCE = 2,

  -- Yellow (slowing) 
  FAMINE = 3,

  -- Black (double-damage) 
  DEATH = 4,

  -- White 
  CONQUEST = 5,
}

---@enum DipFamiliarSubType
-- For `EntityType.FAMILIAR` (3), `FamiliarVariant.DIP` (201). 
TSIL.Enums.DipFamiliarSubType = {
  NORMAL = 0,
  RED = 1,
  CORNY = 2,
  GOLD = 3,
  RAINBOW = 4,
  BLACK = 5,
  WHITE = 6,
  STONE = 12,
  FLAMING = 13,
  STINKY = 14,
  BROWNIE = 20,
}

---@enum BloodClotSubType
-- For `EntityType.FAMILIAR` (3), `FamiliarVariant.BLOOD_BABY` (238). 
TSIL.Enums.BloodClotSubType = {
  RED = 0,
  SOUL = 1,
  BLACK = 2,
  ETERNAL = 3,
  GOLD = 4,
  BONE = 5,
  ROTTEN = 6,

  -- Spawned by the Blood Clot trinket; cannot be turned into health by Sumptorium. 
  RED_NO_SUMPTORIUM = 7,
}

---@enum PickupNullSubType
-- For `EntityType.PICKUP` (5), `PickupVariant.NULL` (0). 
TSIL.Enums.PickupNullSubType = {
  -- Has a chance to spawn any possible pickup, including collectibles. 
  ALL = 0,

  EXCLUDE_COLLECTIBLES_CHESTS = 1,
  EXCLUDE_COLLECTIBLES = 2,
  EXCLUDE_COLLECTIBLES_CHESTS_COINS = 3,
  EXCLUDE_COLLECTIBLES_TRINKETS_CHESTS = 4,
}

---@enum ChargerSubType
-- For `EntityType.CHARGER` (23), `ChargerVariant.CHARGER` (0). 
TSIL.Enums.ChargerSubType = {
  CHARGER = 0,
  MY_SHADOW = 1,
}

---@enum ConstantStoneShooterSubType
--[[
    For `EntityType.CONSTANT_STONE_SHOOTER` (202),
    `ConstantStoneShooterVariant.CONSTANT_STONE_SHOOTER` (0).
    This is the same as the `Direction` enum.
 ]]--
TSIL.Enums.ConstantStoneShooterSubType = {
  LEFT = 0,
  UP = 1,
  RIGHT = 2,
  DOWN = 3,
}

---@enum MotherSubType
-- For `EntityType.MOTHER` (912), `MotherVariant.MOTHER_1` (0). 
TSIL.Enums.MotherSubType = {
  PHASE_1 = 0,
  PHASE_2 = 1,
}

---@enum BloodExplosionSubType
-- For `EntityType.EFFECT` (1000), `EffectVariant.BLOOD_EXPLOSION` (2). 
TSIL.Enums.BloodExplosionSubType = {
  MEDIUM_WITH_LEFTOVER_BLOOD = 0,
  SMALL = 1,
  MEDIUM = 2,
  LARGE = 3,
  GIANT = 4,
  SWIRL = 5,
}

---@enum PoofSubType
-- For `EntityType.EFFECT` (1000), `EffectVariant.POOF_1` (15). 
TSIL.Enums.PoofSubType = {
  NORMAL = 0,
  SMALL = 1,

  -- A sub-type of 2 appears to be the same thing as a sub-type of 0.

  LARGE = 3,
}

---@enum HeavenLightDoorSubType
-- For `EntityType.EFFECT` (1000), `EffectVariant.HEAVEN_LIGHT_DOOR` (39). 
TSIL.Enums.HeavenLightDoorSubType = {
  HEAVEN_DOOR = 0,
  MOONLIGHT = 1,
}

---@enum DiceFloorSubType
-- For `EntityType.EFFECT` (1000), `EffectVariant.DICE_FLOOR` (76). 
TSIL.Enums.DiceFloorSubType = {
  -- Has the same effect as using a D4. 
  ONE_PIP = 0,

  -- Has the same effect as using a D20. 
  TWO_PIP = 1,

  --[[
    Rerolls all pickups and trinkets on the floor, including items inside of a shop, excluding
    collectibles.
    ]]--
  THREE_PIP = 2,

  -- Rerolls all collectibles on the floor. 
  FOUR_PIP = 3,

  -- Has the same effect as using a Forget Me Now. 
  FIVE_PIP = 4,

  -- Has the combined effect of a 1-pip, 3-pip and 4-pip dice room. 
  SIX_PIP = 5,
}

---@enum TallLadderSubType
-- For `EntityType.EFFECT` (1000), `EffectVariant.TALL_LADDER` (156). 
TSIL.Enums.TallLadderSubType = {
  TALL_LADDER = 0,
  STAIRWAY = 1,
}

---@enum PurgatorySubType
-- For `EntityType.EFFECT` (1000), `EffectVariant.PURGATORY` (189). 
TSIL.Enums.PurgatorySubType = {
  RIFT = 0,
  GHOST = 1,
}

--- @enum VariablePersistenceMode
TSIL.Enums.VariablePersistenceMode = {
	NONE = 1,           --The save manager won't do anything with your variable

	RESET_ROOM = 2,     --The save manager will restore the default on a new room
	RESET_LEVEL = 3,    --The save manager will restore the default on a new level
	RESET_RUN = 4,      --The save manager will restore the default on a new run

	REMOVE_ROOM = 5,    --The save manager will remove your variable on a new room
	REMOVE_LEVEL = 6,   --The save manager will remove your variable on a new level
	REMOVE_RUN = 7      --The save manager will remove your variable on a new run
}

---@enum SlotVariant
--- For `EntityType.SLOT` (6).
TSIL.Enums.SlotVariant = {
	SLOT_MACHINE = 1,
	BLOOD_DONATION_MACHINE = 2,
	FORTUNE_TELLING_MACHINE = 3,
	BEGGAR = 4,
	DEVIL_BEGGAR = 5,
	SHELL_GAME = 6,
	KEY_BEGGAR = 7,
	DONATION_MACHINE = 8,
	BOMB_BEGGAR = 9,
	RESTOCK_MACHINE = 10,
	GREED_DONATION_MACHINE = 11,
	DRESSING_TABLE = 12,
	BATTERY_BEGGAR = 13,
	TAINTED_UNLOCK = 14,
	HELL_GAME = 15,
	CRANE_GAME = 16,
	CONFESSIONAL = 17,
	ROTTEN_BEGGAR = 18
}

---@enum LaserVariant
--- For `EntityType.ENTITY_LASER` (7).
TSIL.Enums.LaserVariant = {
  -- Used for Brimstone. 
  THICK_RED = 1,

  --- Used for Technology. 
  THIN_RED = 2,

  SHOOP_DA_WHOOP = 3,

  --- Looks like a squiggly line. 
  PRIDE = 4,

  --- Used for Angel lasers. 
  LIGHT_BEAM = 5,

  --- Used for Mega Blast. 
  GIANT_RED = 6,

  TRACTOR_BEAM = 7,

  --- Used for Circle of Protection; looks like a thinner Angel laser. 
  LIGHT_RING = 8,

  BRIMSTONE_TECHNOLOGY = 9,
  ELECTRIC = 10,
  THICKER_RED = 11,
  THICK_BROWN = 12,
  BEAST = 13,
  THICKER_BRIMSTONE_TECHNOLOGY = 14,
  GIANT_BRIMSTONE_TECHNOLOGY = 15,
}

---@enum KnifeVariant
-- For `EntityType.ENTITY_KNIFE` (8). 
TSIL.Enums.KnifeVariant = {
    MOMS_KNIFE = 8,
    BONE_CLUB = 1,
    BONE_SCYTHE = 2,
    DONKEY_JAWBONE = 3,
    BAG_OF_CRAFTING = 4,
    SUMPTORIUM = 5,
    NOTCHED_AXE = 9,
    SPIRIT_SWORD = 10,
    TECH_SWORD = 11,
}

---@enum GaperVariant
--- For `EntityType.ENTITY_GAPER` (10).
TSIL.Enums.GaperVariant = {
  FROWNING_GAPER = 0,
  GAPER = 1,
  FLAMING_GAPER = 2,
  ROTTEN_GAPER = 3,
}

---@enum GusherVariant
-- For `EntityType.ENTITY_GUSHER` (11). 
TSIL.Enums.GusherVariant = {
  GUSHER = 0,
  PACER = 1,
}

---@enum PooterVariant
-- For `EntityType.ENTITY_POOTER` (14). 
TSIL.Enums.PooterVariant = {
  POOTER = 0,
  SUPER_POOTER = 1,
  TAINTED_POOTER = 2,
}

---@enum ClottyVariant
-- For `EntityType.ENTITY_CLOTTY` (15). 
TSIL.Enums.ClottyVariant = {
  CLOTTY = 0,
  CLOT = 1,
  BLOB = 2,
  GRILLED_CLOTTY = 3,
}

---@enum MulliganVariant
-- For `EntityType.ENTITY_MULLIGAN` (16). 
TSIL.Enums.MulliganVariant = {
  MULLIGAN = 0,
  MULLIGOON = 1,
  MULLIBOOM = 2,
}

---@enum ShopKeeperVariant
-- For `EntityType.ENTITY_SHOPKEEPER` (17). 
TSIL.Enums.ShopkeeperVariant = {
  SHOPKEEPER = 0,
  SECRET_ROOM_KEEPER = 1,
  ERROR_ROOM_KEEPER = 2,
  SPECIAL_SHOPKEEPER = 3,
  SPECIAL_SECRET_ROOM_KEEPER = 4,
}

---@enum LarryJrVariant
-- For `EntityType.ENTITY_LARRY_JR` (19). 
TSIL.Enums.LarryJrVariant = {
  LARRY_JR = 0,
  THE_HOLLOW = 1,
  TUFF_TWIN = 2,
  THE_SHELL = 3,
}

---@enum HiveVariant
-- For `EntityType.ENTITY_HIVE` (22). 
TSIL.Enums.HiveVariant = {
  HIVE = 0,
  DROWNED_HIVE = 1,
  HOLY_MULLIGAN = 2,
  TAINTED_MULLIGAN = 3,
}

---@enum ChargerVariant
-- For `EntityType.ENTITY_CHARGER` (23). 
TSIL.Enums.ChargerVariant = {
  CHARGER = 0,
  DROWNED_CHARGER = 1,
  DANK_CHARGER = 2,
  CARRION_PRINCESS = 3,
}

---@enum GlobinVariant
-- For `EntityType.ENTITY_GLOBIN` (24). 
TSIL.Enums.GlobinVariant = {
  GLOBIN = 0,
  GAZING_GLOBIN = 1,
  DANK_GLOBIN = 2,
  CURSED_GLOBIN = 3,
}

---@enum BoomFlyVariant
-- For `EntityType.ENTITY_BOOM_FLY` (25). 
TSIL.Enums.BoomFlyVariant = {
  BOOM_FLY = 0,
  RED_BOOM_FLY = 1,
  DROWNED_BOOM_FLY = 2,
  DRAGON_FLY = 3,
  BONE_FLY = 4,
  SICK_BOOM_FLY = 5,
  TAINTED_BOOM_FLY = 6,
}

---@enum MawVariant
-- For `EntityType.ENTITY_MAW` (26). 
TSIL.Enums.MawVariant = {
  MAW = 0,
  RED_MAW = 1,
  PSYCHIC_MAW = 2,
}

---@enum HostVariant
-- For `EntityType.ENTITY_HOST` (27). 
TSIL.Enums.HostVariant = {
  HOST = 0,
  RED_HOST = 1,
  HARD_HOST = 2,
}

---@enum ChubVariant
-- For `EntityType.ENTITY_CHUB` (28). 
TSIL.Enums.ChubVariant = {
  CHUB = 0,
  CHAD = 1,
  CARRION_QUEEN = 2,
}

---@enum HopperVariant
-- For `EntityType.ENTITY_HOPPER` (29). 
TSIL.Enums.HopperVariant = {
  HOPPER = 0,
  TRITE = 1,
  EGGY = 2,
  TAINTED_HOPPER = 3,
}

---@enum BoilVariant
-- For `EntityType.ENTITY_BOIL` (30). 
TSIL.Enums.BoilVariant = {
  BOIL = 0,
  GUT = 1,
  SACK = 2,
}

---@enum SpittyVariant
-- For `EntityType.ENTITY_SPITTY` (31). 
TSIL.Enums.SpittyVariant = {
  SPITTY = 0,
  TAINTED_SPITTY = 1,
}

---@enum FireplaceVariant
--[[
    For `EntityType.ENTITY_FIREPLACE` (33).
    Also see the `FireplaceGridEntityVariant` enum, which is different and used for the grid entity
    version.
]]--
TSIL.Enums.FireplaceVariant = {
  NORMAL = 0,
  RED = 1,
  BLUE = 2,
  PURPLE = 3,
  WHITE = 4,
  MOVEABLE = 10,
  COAL = 11,
  MOVEABLE_BLUE = 12,
  MOVEABLE_PURPLE = 13,
}

---@enum LeaperVariant
-- For `EntityType.ENTITY_LEAPER` (34). 
TSIL.Enums.LeaperVariant = {
  LEAPER = 0,
  STICKY_LEAPER = 1,
}

---@enum MrMawVariant
-- For `EntityType.ENTITY_MR_MAW` (35). 
TSIL.Enums.MrMawVariant = {
  MR_MAW = 0,
  MR_MAW_HEAD = 1,
  MR_RED_MAW = 2,
  MR_RED_MAW_HEAD = 3,
  MR_MAW_NECK = 10,
}

---@enum BabyVariant
-- For `EntityType.ENTITY_BABY` (38). 
TSIL.Enums.BabyVariant = {
  BABY = 0,
  ANGELIC_BABY = 1,
  ULTRA_PRIDE_BABY = 2,
  WRINKLY_BABY = 3,
}

---@enum VisVariant
-- For `EntityType.ENTITY_VIS` (39). 
TSIL.Enums.VisVariant = {
  VIS = 0,
  DOUBLE_VIS = 1,
  CHUBBER = 2,
  SCARRED_DOUBLE_VIS = 3,
  CHUBBER_PROJECTILE = 22,
}

---@enum GutsVariant
-- For `EntityType.ENTITY_GUTS` (40). 
TSIL.Enums.GutsVariant = {
  GUTS = 0,
  SCARRED_GUTS = 1,
  SLOG = 2,
}

---@enum KnightVariant
-- For `EntityType.ENTITY_KNIGHT` (41). 
TSIL.Enums.KnightVariant = {
  KNIGHT = 0,
  SELFLESS_KNIGHT = 1,
  LOOSE_KNIGHT = 2,
  BRAINLESS_KNIGHT = 3,
  BLACK_KNIGHT = 4,
}

---@enum GrimaceVariant
-- For `EntityType.ENTITY_GRIMACE` (42). 
TSIL.Enums.GrimaceVariant = {
  STONE_GRIMACE = 0,
  VOMIT_GRIMACE = 1,
  TRIPLE_GRIMACE = 2,
}

---@enum Monstro2Variant
-- For `EntityType.ENTITY_MONSTRO_2` (43). 
TSIL.Enums.Monstro2Variant = {
  MONSTRO_2 = 0,
  GISH = 1,
}

---@enum PokyVariant
-- For `EntityType.ENTITY_POKY` (44). 
TSIL.Enums.PokyVariant = {
  POKY = 0,
  SLIDE = 1,
}

---@enum MomVariant
-- For `EntityType.ENTITY_MOM` (45). 
TSIL.Enums.MomVariant = {
  MOM = 0,
  STOMP = 10,
}

---@enum SlothVariant
-- For `EntityType.ENTITY_SLOTH` (46). 
TSIL.Enums.SlothVariant = {
  SLOTH = 0,
  SUPER_SLOTH = 1,
  ULTRA_PRIDE = 2,
}

---@enum LustVariant
-- For `EntityType.ENTITY_LUST` (47). 
TSIL.Enums.LustVariant = {
  LUST = 0,
  SUPER_LUST = 1,
}

---@enum WrathVariant
-- For `EntityType.ENTITY_WRATH` (48). 
TSIL.Enums.WrathVariant = {
  WRATH = 0,
  SUPER_WRATH = 1,
}

---@enum GluttonyVariant
-- For `EntityType.ENTITY_GLUTTONY` (49). 
TSIL.Enums.GluttonyVariant = {
  GLUTTONY = 0,
  SUPER_GLUTTONY = 1,
}

---@enum GreedVariant
-- For `EntityType.ENTITY_GREED` (50). 
TSIL.Enums.GreedVariant = {
  GREED = 0,
  SUPER_GREED = 1,
}

---@enum EnvyVariant
-- For `EntityType.ENTITY_ENVY` (51). 
TSIL.Enums.EnvyVariant = {
  ENVY = 0,
  SUPER_ENVY = 1,
  ENVY_BIG = 10,
  SUPER_ENVY_BIG = 11,
  ENVY_MEDIUM = 20,
  SUPER_ENVY_MEDIUM = 21,
  ENVY_SMALL = 30,
  SUPER_ENVY_SMALL = 31,
}

---@enum PrideVariant
-- For `EntityType.ENTITY_PRIDE` (52). 
TSIL.Enums.PrideVariant = {
  PRIDE = 0,
  SUPER_PRIDE = 1,
}

---@enum DopleVariant
-- For `EntityType.ENTITY_DOPLE` (53). 
TSIL.Enums.DopleVariant = {
  DOPLE = 0,
  EVIL_TWIN = 1,
}

---@enum LeechVariant
-- For `EntityType.ENTITY_LEECH` (55). 
TSIL.Enums.LeechVariant = {
  LEECH = 0,
  KAMIKAZE_LEECH = 1,
  HOLY_LEECH = 2,
}

---@enum MembrainVariant
-- For `EntityType.ENTITY_MEMBRAIN` (57). 
TSIL.Enums.MemBrainVariant = {
  MEMBRAIN = 0,
  MAMA_GUTS = 1,
  DEAD_MEAT = 2,
}

---@enum ParaBiteVariant
-- For `EntityType.ENTITY_PARA_BITE` (58). 
TSIL.Enums.ParaBiteVariant = {
  PARA_BITE = 0,
  SCARRED_PARA_BITE = 1,
}

---@enum EyeVariant
-- For `EntityType.ENTITY_EYE` (60). 
TSIL.Enums.EyeVariant = {
  EYE = 0,
  BLOODSHOT_EYE = 1,
  HOLY_EYE = 2,
}

---@enum SuckerVariant
-- For `EntityType.ENTITY_SUCKER` (61). 
TSIL.Enums.SuckerVariant = {
  SUCKER = 0,
  SPIT = 1,
  SOUL_SUCKER = 2,
  INK = 3,
  MAMA_FLY = 4,
  BULB = 5,
  BLOOD_FLY = 6,
  TAINTED_SUCKER = 7,
}

---@enum PinVariant
-- For `EntityType.ENTITY_PIN` (62). 
TSIL.Enums.PinVariant = {
  PIN = 0,
  SCOLEX = 1,
  FRAIL = 2,
  WORMWOOD = 3,
}

---@enum WarVariant
-- For `EntityType.ENTITY_WAR` (65). 
TSIL.Enums.WarVariant = {
  WAR = 0,
  CONQUEST = 1,
  WAR_WITHOUT_HORSE = 2,
}

---@enum DeathVariant
-- For `EntityType.ENTITY_DEATH` (66). 
TSIL.Enums.DeathVariant = {
  DEATH = 0,
  DEATH_SCYTHE = 10,
  DEATH_HORSE = 20,
  DEATH_WITHOUT_HORSE = 30,
}

---@enum DukeVariant
-- For `EntityType.ENTITY_DUKE` (67). 
TSIL.Enums.DukeVariant = {
  DUKE_OF_FLIES = 0,
  THE_HUSK = 1,
}

---@enum PeepVariant
-- For `EntityType.ENTITY_PEEP` (68). 
TSIL.Enums.PeepVariant = {
  PEEP = 0,
  BLOAT = 1,
  PEEP_EYE = 10,
  BLOAT_EYE = 11,
}

---@enum LokiVariant
-- For `EntityType.ENTITY_LOKI` (69). 
TSIL.Enums.LokiVariant = {
  LOKI = 0,
  LOKII = 1,
}

---@enum FistulaVariant
--[[
    For:
        - `EntityType.ENTITY_FISTULA_BIG` (71)
        - `EntityType.ENTITY_FISTULA_MEDIUM` (72)
        - `EntityType.ENTITY_FISTULA_SMALL` (73)
]]--
TSIL.Enums.FistulaVariant = {
  FISTULA = 0,
  TERATOMA = 1,
}

---@enum MomsHeartVariant
-- For `EntityType.ENTITY_MOMS_HEART` (78). 
TSIL.Enums.MomsHeartVariant = {
  MOMS_HEART = 0,
  IT_LIVES = 1,
  MOMS_GUTS = 2,
}

---@enum GeminiVariant
-- For `EntityType.ENTITY_GEMINI` (79). 
TSIL.Enums.GeminiVariant = {
  GEMINI = 0,
  STEVEN = 1,
  BLIGHTED_OVUM = 2,
  GEMINI_BABY = 10,
  STEVEN_BABY = 11,
  BLIGHTED_OVUM_BABY = 12,
  UMBILICAL_CORD = 20,
}

---@enum FallenVariant
-- For `EntityType.ENTITY_FALLEN` (81). 
TSIL.Enums.FallenVariant = {
  FALLEN = 0,
  KRAMPUS = 1,
}

---@enum SatanVariant
-- For `EntityType.ENTITY_SATAN` (84). 
TSIL.Enums.SatanVariant = {
  SATAN = 0,
  STOMP = 10,
}

---@enum GurgleVariant
-- For `EntityType.ENTITY_GURGLE` (87). 
TSIL.Enums.GurgleVariant = {
  GURGLE = 0,
  CRACKLE = 1,
}

---@enum WalkingBoilVariant
-- For `EntityType.ENTITY_WALKING_BOIL` (88). 
TSIL.Enums.WalkingBoilVariant = {
  WALKING_BOIL = 0,
  WALKING_GUT = 1,
  WALKING_SACK = 2,
}

---@enum HeartVariant
-- For `EntityType.ENTITY_HEART` (92). 
TSIL.Enums.HeartVariant = {
  HEART = 0,
  HALF_HEART = 1,
}

---@enum MaskVariant
-- For `EntityType.ENTITY_MASK` (93). 
TSIL.Enums.MaskVariant = {
  MASK = 0,
  MASK_2 = 1,
}

---@enum WidowVariant
-- For `EntityType.ENTITY_WIDOW` (100). 
TSIL.Enums.WidowVariant = {
  WIDOW = 0,
  THE_WRETCHED = 1,
}

---@enum DaddyLongLegsVariant
-- For `EntityType.ENTITY_DADDY_LONG_LEGS` (101). 
TSIL.Enums.DaddyLongLegsVariant = {
  DADDY_LONG_LEGS = 0,
  TRIACHNID = 1,
}

---@enum IsaacVariant
-- For `EntityType.ENTITY_ISAAC` (102). 
TSIL.Enums.IsaacVariant = {
  ISAAC = 0,
  BLUE_BABY = 1,
  BLUE_BABY_HUSH = 2,
}

---@enum ConstantStoneShooterVariant
-- For `EntityType.ENTITY_CONSTANT_STONE_SHOOTER` (202). 
TSIL.Enums.ConstantStoneShooterVariant = {
  CONSTANT_STONE_SHOOTER = 0,
  CROSS_STONE_SHOOTER = 10,
  CROSS_STONE_SHOOTER_ALWAYS_ON = 11,
}

---@enum BabyLongLegsVariant
-- For `EntityType.ENTITY_BABY_LONG_LEGS` (206). 
TSIL.Enums.BabyLongLegsVariant = {
  BABY_LONG_LEGS = 0,
  SMALL_BABY_LONG_LEGS = 1,
}

---@enum CrazyLongLegsVariant
-- For `EntityType.ENTITY_CRAZY_LONG_LEGS` (207). 
TSIL.Enums.CrazyLongLegsVariant = {
  CRAZY_LONG_LEGS = 0,
  SMALL_CRAZY_LONG_LEGS = 1,
}

---@enum FattyVariant
-- For `EntityType.ENTITY_FATTY` (208). 
TSIL.Enums.FattyVariant = {
  FATTY = 0,
  PALE_FATTY = 1,
  FLAMING_FATTY = 2,
}

---@enum DeathsHeadVariant
-- For `EntityType.ENTITY_DEATHS_HEAD` (212). 
TSIL.Enums.DeathsHeadVariant = {
  DEATHS_HEAD = 0,
  DANK_DEATHS_HEAD = 1,
  CURSED_DEATHS_HEAD = 2,
  BRIMSTONE_DEATHS_HEAD = 3,
  RED_SKULL = 4,
}

---@enum SwingerVariant
-- For `EntityType.ENTITY_SWINGER` (216). 
TSIL.Enums.SwingerVariant = {
  SWINGER = 0,
  SWINGER_HEAD = 1,
  SWINGER_NECK = 10,
}

---@enum DipVariant
-- For `EntityType.ENTITY_DIP` (217). 
TSIL.Enums.DipVariant = {
  DIP = 0,
  CORN = 1,
  BROWNIE_CORN = 2,
  BIG_CORN = 3,
}

---@enum SquirtVariant
-- For `EntityType.ENTITY_SQUIRT` (220). 
TSIL.Enums.SquirtVariant = {
  SQUIRT = 0,
  DANK_SQUIRT = 1,
}

---@enum SkinnyVariant
-- For `EntityType.ENTITY_SKINNY` (226). 
TSIL.Enums.SkinnyVariant = {
  SKINNY = 0,
  ROTTY = 1,
  CRISPY = 2,
}

---@enum BonyVariant
-- For `EntityType.ENTITY_BONY` (227). 
TSIL.Enums.BonyVariant = {
  BONY = 0,
  HOLY_BONY = 1,
}

---@enum HomunculusVariant
-- For `EntityType.ENTITY_HOMUNCULUS` (228). 
TSIL.Enums.HomunculusVariant = {
  HOMUNCULUS = 0,
  HOMUNCULUS_CORD = 10,
}

---@enum TumorVariant
-- For `EntityType.ENTITY_TUMOR` (229). 
TSIL.Enums.TumorVariant = {
  TUMOR = 0,
  PLANETOID = 1,
}

---@enum NerveEndingVariant
-- For `EntityType.ENTITY_NERVE_ENDING` (231). 
TSIL.Enums.NerveEndingVariant = {
  NERVE_ENDING = 0,
  NERVE_ENDING_2 = 1,
}

---@enum GurglingVariant
-- For `EntityType.ENTITY_GURGLING` (237). 
TSIL.Enums.GurglingVariant = {
  GURGLING = 0,
  GURGLING_BOSS = 1,
  TURDLING = 2,
}

---@enum GrubVariant
-- For `EntityType.ENTITY_GRUB` (239). 
TSIL.Enums.GrubVariant = {
  GRUB = 0,
  CORPSE_EATER = 1,
  CARRION_RIDER = 2,
}

---@enum WallCreepVariant
-- For `EntityType.ENTITY_WALL_CREEP` (240). 
TSIL.Enums.WallCreepVariant = {
  WALL_CREEP = 0,
  SOY_CREEP = 1,
  RAG_CREEP = 2,
  TAINTED_SOY_CREEP = 3,
}

---@enum RageCreepVariant
-- For `EntityType.ENTITY_RAGE_CREEP` (241). 
TSIL.Enums.RageCreepVariant = {
  RAGE_CREEP = 0,
  SPLIT_RAGE_CREEP = 1,
}

---@enum RoundWormVariant
-- For `EntityType.ENTITY_ROUND_WORM` (244). 
TSIL.Enums.RoundWormVariant = {
  ROUND_WORM = 0,
  TUBE_WORM = 1,
  TAINTED_ROUND_WORM = 2,
  TAINTED_TUBE_WORM = 3,
}

---@enum PoopEntityVariant
-- For `EntityType.ENTITY_POOP` (245). 
TSIL.Enums.PoopEntityVariant = {
  NORMAL = 0,
  GOLDEN = 1,
  STONE = 11,
  CORNY = 12,
  BURNING = 13,
  STINKY = 14,
  BLACK = 15,
  HOLY = 16,
}

---@enum RaglingVariant
-- For `EntityType.ENTITY_RAGLING` (246). 
TSIL.Enums.RaglingVariant = {
  RAGLING = 0,
  RAG_MANS_RAGLING = 1,
}

---@enum BegottenVariant
-- For `EntityType.ENTITY_BEGOTTEN` (251). 
TSIL.Enums.BegottenVariant = {
  BEGOTTEN = 0,
  BEGOTTEN_CHAIN = 10,
}

---@enum ConjoinedFattyVariant
-- For `EntityType.ENTITY_CONJOINED_FATTY` (257). 
TSIL.Enums.ConjoinedFattyVariant = {
  CONJOINED_FATTY = 0,
  BLUE_CONJOINED_FATTY = 1,
}

---@enum HauntVariant
-- For `EntityType.ENTITY_THE_HAUNT` (260). 
TSIL.Enums.HauntVariant = {
  HAUNT = 0,
  LIL_HAUNT = 10,
}

---@enum DingleVariant
-- For `EntityType.ENTITY_DINGLE` (261). 
TSIL.Enums.DingleVariant = {
  DINGLE = 0,
  DANGLE = 1,
}

---@enum MamaGurdyVariant
-- For `EntityType.ENTITY_MAMA_GURDY` (266). 
TSIL.Enums.MamaGurdyVariant = {
  MAMA_GURDY = 0,
  LEFT_HAND = 1,
  RIGHT_HAND = 2,
}

---@enum PolycephalusVariant
-- For `EntityType.ENTITY_POLYCEPHALUS` (269). 
TSIL.Enums.PolycephalusVariant = {
  POLYCEPHALUS = 0,
  THE_PILE = 1,
}

---@enum AngelVariant
-- For `EntityType.ENTITY_URIEL` (271) and `EntityType.ENTITY_GABRIEL` (272). 
TSIL.Enums.AngelVariant = {
  NORMAL = 0,
  FALLEN = 1,
}

---@enum LambVariant
-- For `EntityType.ENTITY_THE_LAMB` (273). 
TSIL.Enums.LambVariant = {
  LAMB = 0,
  BODY = 10,
}

---@enum MegaSatanVariant
-- For `EntityType.ENTITY_MEGA_SATAN` (274) and `EntityType.ENTITY_MEGA_SATAN_2` (275). 
TSIL.Enums.MegaSatanVariant = {
  MEGA_SATAN = 0,
  MEGA_SATAN_RIGHT_HAND = 1,
  MEGA_SATAN_LEFT_HAND = 2,
}

---@enum PitfallVariant
-- For `EntityType.ENTITY_PITFALL` (291). 
TSIL.Enums.PitfallVariant = {
  PITFALL = 0,
  SUCTION_PITFALL = 1,
  TELEPORT_PITFALL = 2,
}

---@enum MoveableTNTVariant
-- For `EntityType.ENTITY_MOVABLE_TNT` (292). 
TSIL.Enums.MoveableTNTVariant = {
  MOVEABLE_TNT = 0,
  MINE_CRAFTER = 1,
}

---@enum UltraCoinVariant
-- For `EntityType.ENTITY_ULTRA_COIN` (293). 
TSIL.Enums.UltraCoinVariant = {
  SPINNER = 0,
  KEY = 1,
  BOMB = 2,
  HEART = 3,
}

---@enum StoneyVariant
-- For `EntityType.ENTITY_STONEY` (302). 
TSIL.Enums.StoneyVariant = {
  STONEY = 0,
  CROSS_STONEY = 10,
}

---@enum PortalVariant
-- For `EntityType.ENTITY_PORTAL` (306). 
TSIL.Enums.PortalVariant = {
  PORTAL = 0,
  LIL_PORTAL = 1,
}

---@enum LeperVariant
-- For `EntityType.ENTITY_LEPER` (310). 
TSIL.Enums.LeperVariant = {
  LEPER = 0,
  LEPER_FLESH = 1,
}

---@enum MrMineVariant
-- For `EntityType.ENTITY_MR_MINE` (311). 
TSIL.Enums.MrMineVariant = {
  MR_MINE = 0,
  MR_MINE_NECK = 10,
}

---@enum LittleHornVariant
-- For `EntityType.ENTITY_LITTLE_HORN` (404). 
TSIL.Enums.LittleHornVariant = {
  LITTLE_HORN = 0,
  DARK_BALL = 1,
}

---@enum RagManVariant
-- For `EntityType.ENTITY_RAG_MAN` (405). 
TSIL.Enums.RagManVariant = {
  RAG_MAN = 0,
  RAG_MAN_HEAD = 1,
}

---@enum UltraGreedVariant
-- For `EntityType.ENTITY_ULTRA_GREED` (406). 
TSIL.Enums.UltraGreedVariant = {
  ULTRA_GREED = 0,
  ULTRA_GREEDIER = 1,
}

---@enum RagMegaVariant
-- For `EntityType.ENTITY_RAG_MEGA` (409). 
TSIL.Enums.RagMegaVariant = {
  RAG_MEGA = 0,
  PURPLE_BALL = 1,
  REBIRTH_PILLAR = 2,
}

---@enum BigHornVariant
-- For `EntityType.ENTITY_BIG_HORN` (411). 
TSIL.Enums.BigHornVariant = {
  BIG_HORN = 0,
  SMALL_HOLE = 1,
  BIG_HOLE = 2,
}

---@enum BloodPuppyVariant
-- For `EntityType.ENTITY_BLOOD_PUPPY` (802). 
TSIL.Enums.BloodPuppyVariant = {
  SMALL = 0,
  LARGE = 1,
}

---@enum SubHorfVariant
-- For `EntityType.ENTITY_SUB_HORF` (812). 
TSIL.Enums.SubHorfVariant = {
  SUB_HORF = 0,
  TAINTED_SUB_HORF = 1,
}

---@enum PoltyVariant
-- For `EntityType.ENTITY_POLTY` (816). 
TSIL.Enums.PoltyVariant = {
  POLTY = 0,
  KINETI = 1,
}

---@enum PreyVariant
-- For `EntityType.ENTITY_PREY` (817). 
TSIL.Enums.PreyVariant = {
  PREY = 0,
  MULLIGHOUL = 1,
}

---@enum RockSpiderVariant
-- For `EntityType.ENTITY_ROCK_SPIDER` (818). 
TSIL.Enums.RockSpiderVariant = {
  ROCK_SPIDER = 0,
  TINTED_ROCK_SPIDER = 1,
  COAL_SPIDER = 2,
}

---@enum FlyBombVariant
-- For `EntityType.ENTITY_FLY_BOMB` (819). 
TSIL.Enums.FlyBombVariant = {
  FLY_BOMB = 0,
  ETERNAL_FLY_BOMB = 1,
}

---@enum DannyVariant
-- For `EntityType.ENTITY_DANNY` (820). 
TSIL.Enums.DannyVariant = {
  DANNY = 0,
  COAL_BOY = 1,
}

---@enum GyroVariant
-- For `EntityType.ENTITY_GYRO` (824). 
TSIL.Enums.GyroVariant = {
  GYRO = 0,
  GRILLED_GYRO = 1,
}

---@enum FacelessVariant
-- For `EntityType.ENTITY_FACELESS` (827). 
TSIL.Enums.FacelessVariant = {
  FACELESS = 0,
  TAINTED_FACELESS = 1,
}

---@enum MoleVariant
-- For `EntityType.ENTITY_MOLE` (829). 
TSIL.Enums.MoleVariant = {
  MOLE = 0,
  TAINTED_MOLE = 1,
}

---@enum BigBonyVariant
-- For `EntityType.ENTITY_BIG_BONY` (830). 
TSIL.Enums.BigBonyVariant = {
  BIG_BONY = 0,
  BIG_BONE = 10,
}

---@enum GuttedFattyVariant
-- For `EntityType.ENTITY_GUTTED_FATTY` (831). 
TSIL.Enums.GuttedFattyVariant = {
  GUTTED_FATTY = 0,
  GUTTY_FATTY_EYE = 10,
  FESTERING_GUTS = 20,
}

---@enum ExorcistVariant
-- For `EntityType.ENTITY_EXORCIST` (832). 
TSIL.Enums.ExorcistVariant = {
  EXORCIST = 0,
  FANATIC = 1,
}

---@enum WhipperVariant
-- For `EntityType.ENTITY_WHIPPER` (834). 
TSIL.Enums.WhipperVariant = {
  WHIPPER = 0,
  SNAPPER = 1,
  FLAGELLANT = 2,
}

---@enum PeeperFattyVariant
-- For `EntityType.ENTITY_PEEPER_FATTY` (835). 
TSIL.Enums.PeeperFattyVariant = {
  PEEPING_FATTY = 0,
  PEEPING_FATTY_EYE = 10,
}

---@enum RevenantVariant
-- For `EntityType.ENTITY_REVENANT` (841). 
TSIL.Enums.RevenantVariant = {
  REVENANT = 0,
  QUAD_REVENANT = 1,
}

---@enum CanaryVariant
-- For `EntityType.ENTITY_CANARY` (843). 
TSIL.Enums.CanaryVariant = {
  CANARY = 0,
  FOREIGNER = 1,
}

---@enum Gaper2Variant
-- For `EntityType.ENTITY_GAPER_L2` (850). 
TSIL.Enums.Gaper2Variant = {
  GAPER = 0,
  HORF = 1,
  GUSHER = 2,
}

---@enum Charger2Variant
-- For `EntityType.ENTITY_CHARGER_L2` (855). 
TSIL.Enums.Charger2Variant = {
  CHARGER = 0,
  ELLEECH = 1,
}

---@enum EvisVariant
-- For `EntityType.ENTITY_EVIS` (865). 
TSIL.Enums.EvisVariant = {
  EVIS = 0,
  EVIS_GUTS = 10,
}

---@enum DarkEsauVariant
-- For `EntityType.ENTITY_DARK_ESAU` (866). 
TSIL.Enums.DarkEsauVariant = {
  DARK_ESAU = 0,
  PIT = 1,
}

---@enum DumpVariant
-- For `EntityType.ENTITY_DUMP` (876). 
TSIL.Enums.DumpVariant = {
  DUMP = 0,
  DUMP_HEAD = 1,
}

---@enum NeedleVariant
-- For `EntityType.ENTITY_NEEDLE` (881). 
TSIL.Enums.NeedleVariant = {
  NEEDLE = 0,
  PASTY = 1,
}

---@enum CultistVariant
-- For `EntityType.ENTITY_CULTIST` (885). 
TSIL.Enums.CultistVariant = {
  CULTIST = 0,
  BLOOD_CULTIST = 1,
  BONE_TRAP = 10,
}

---@enum VisFattyVariant
-- For `EntityType.ENTITY_VIS_FATTY` (886). 
TSIL.Enums.VisFattyVariant = {
  VIS_FATTY = 0,
  FETAL_DEMON = 1,
}

---@enum GoatVariant
-- For `EntityType.ENTITY_GOAT` (891). 
TSIL.Enums.GoatVariant = {
  GOAT = 0,
  BLACK_GOAT = 1,
}

---@enum VisageVariant
-- For `EntityType.ENTITY_VISAGE` (903). 
TSIL.Enums.VisageVariant = {
  VISAGE = 0,
  VISAGE_MASK = 1,
  VISAGE_CHAIN = 10,
  VISAGE_PLASMA = 20,
}

---@enum SirenVariant
-- For `EntityType.ENTITY_SIREN` (904). 
TSIL.Enums.SirenVariant = {
  SIREN = 0,
  SIREN_SKULL = 1,
  SIREN_HELPER_PROJECTILE = 10,
}

---@enum ScourgeVariant
-- For `EntityType.ENTITY_SCOURGE` (909). 
TSIL.Enums.ScourgeVariant = {
  SCOURGE = 0,
  SCOURGE_CHAIN = 10,
}

---@enum ChimeraVariant
-- For `EntityType.ENTITY_CHIMERA` (910). 
TSIL.Enums.ChimeraVariant = {
  CHIMERA = 0,
  CHIMERA_BODY = 1,
  CHIMERA_HEAD = 2,
}

---@enum RotgutVariant
-- For `EntityType.ENTITY_ROTGUT` (911). 
TSIL.Enums.RotgutVariant = {
  PHASE_1_HEAD = 0,
  PHASE_2_MAGGOT = 1,
  PHASE_3_HEART = 2,
}

---@enum MotherVariant
-- For `EntityType.ENTITY_MOTHER` (912). 
TSIL.Enums.MotherVariant = {
  --[[
    The body that is attached to the top of the screen in phase 1. During phase 2, it remains alive
    but is inactive.
    ]]--
  MOTHER_1 = 0,

  -- The circular body that moves around in phase 2. 
  MOTHER_2 = 10,

  BALL = 100,
}

---@enum SingeVariant
-- For `EntityType.ENTITY_SINGE` (915). 
TSIL.Enums.SingeVariant = {
  SINGE = 0,
  SINGE_BALL = 1,
}

---@enum RaglichVariant
-- For `EntityType.ENTITY_RAGLICH` (919). 
TSIL.Enums.RaglichVariant = {
  RAGLICH = 0,
  RAGLICH_ARM = 1,
}

---@enum ClutchVariant
-- For `EntityType.ENTITY_CLUTCH` (921). 
TSIL.Enums.ClutchVariant = {
  CLUTCH = 0,
  CLUTCH_ORBITAL = 1,
}

---@enum DogmaVariant
-- For `EntityType.ENTITY_DOGMA` (950). 
TSIL.Enums.DogmaVariant = {
  DOGMA_PHASE_1 = 0,
  TV = 1,
  ANGEL_PHASE_2 = 2,
  ANGEL_BABY_UNUSED = 10,
}

---@enum BeastVariant
-- For `EntityType.ENTITY_BEAST` (951). 
TSIL.Enums.BeastVariant = {
  BEAST = 0,
  STALACTITE = 1,
  ROCK_PROJECTILE = 2,
  SOUL = 3,
  ULTRA_FAMINE = 10,
  ULTRA_FAMINE_FLY = 11,
  ULTRA_PESTILENCE = 20,
  ULTRA_PESTILENCE_FLY = 21,
  ULTRA_PESTILENCE_MAGGOT = 22,
  ULTRA_PESTILENCE_FLY_BALL = 23,
  ULTRA_WAR = 30,
  ULTRA_WAR_BOMB = 31,
  ULTRA_DEATH = 40,
  ULTRA_DEATH_SCYTHE = 41,
  ULTRA_DEATH_HEAD = 42,
  BACKGROUND_BEAST = 100,
  BACKGROUND_FAMINE = 101,
  BACKGROUND_PESTILENCE = 102,
  BACKGROUND_WAR = 103,
  BACKGROUND_DEATH = 104,
}

---@enum GenericPropVariant
-- For `EntityType.ENTITY_GENERIC_PROP` (960). 
TSIL.Enums.GenericPropVariant = {
  GENERIC_PROP = 0,
  MOMS_DRESSER = 1,
  MOMS_VANITY = 2,
  COUCH = 3,
  TV = 4,
}

--- Helper function to add and remove familiars based on a target amount that you specify.
---
--- This is a convenience wrapper around the `EntityPlayer.CheckFamiliar` method. Use this helper
--- function instead so that you do not have to retrieve the `ItemConfigItem` and so that you do not
--- specify an incorrect RNG object. (The vanilla method is bugged in that it does not increment the
--- RNG object; see the documentation of the method for more details.)
---
--- This function is meant to be called in the `EVALUATE_CACHE` callback (when the cache flag is
--- equal to `CacheFlag.FAMILIARS`).
---
--- Note that this function is only meant to be used in special circumstances where the familiar
--- count is completely custom and does not correspond to the amount of collectibles. For the general
--- case, use the `checkFamiliarFromCollectibles` helper function instead.
---
--- Note that this will spawn familiars with a completely random `InitSeed`. When calculating random
--- events for this familiar, you should use a data structure that maps familiar `InitSeed` to RNG
--- objects that are initialized based on the seed from `EntityPlayer.GetCollectibleRNG(collectibleType)`.
---@param player EntityPlayer
---@param collectibleType CollectibleType
---@param targetCount integer
---@param familiarVariant FamiliarVariant
---@param familiarSubtype integer? @ Optional. The SubType of the familiar to spawn or remove. If not specified, it will seach for existing familiars of all SubTypes, and spawn new familiars with a SubType of 0.
function TSIL.Familiars.CheckFamiliar(player, collectibleType, targetCount, familiarVariant, familiarSubtype)
end

--- Helper function to add and remove familiars based on the amount of associated collectibles that a
--- player has.
---
--- Use this helper function instead of invoking the `EntityPlayer.CheckFamiliar` method directly so
--- that the target count is handled automatically.
---
--- This function is meant to be called in the `EVALUATE_CACHE` callback (when the cache flag is
--- equal to `CacheFlag.FAMILIARS`).
---
--- Use this function when the amount of familiars should be equal to the amount of associated
--- collectibles that the player has (plus any extras from having used Box of Friends or Monster
--- Manual). If you instead need to have a custom amount of familiars, use the `checkFamiliars`
--- function instead.
---
--- Note that this will spawn familiars with a completely random `InitSeed`. When calculating random
--- events for this familiar, you should use a data structure that maps familiar `InitSeed` to RNG
--- objects that are initialized based on the seed from
--- `EntityPlayer.GetCollectibleRNG(collectibleType)`.
---@param player EntityPlayer
---@param collectibleType CollectibleType
---@param familiarVariant FamiliarVariant
---@param familiarSubtype integer? @ Optional. The SubType of the familiar to spawn or remove. If not specified, it will seach for existing familiars of all SubTypes, and spawn new familiars with a SubType of 0.
function TSIL.Familiars.CheckFamiliarFromCollectibles(player, collectibleType, familiarVariant, familiarSubtype)
end

--- Helper function to get all familiars that belong to a given player.
---@param player EntityPlayer
---@return EntityFamiliar[]
function TSIL.Familiars.GetPlayerFamiliars(player)
end

--- Helper function to get the corresponding "Siren Helper" entity for a stolen familiar.
---
--- When The Siren boss "steals" your familiars, a hidden "Siren Helper" entity is spawned to control
--- each familiar stolen. (Checking for the presence of this entity seems to be the only way to
--- detect when the Siren steals a familiar.)
---@param familiar EntityFamiliar
---@return Entity? @ Returns the hitdden "Siren Helper" entity corresponding to the given familiar, if it exists. Returns nil otherwise.
function TSIL.Familiars.GetSirenHelper(familiar)
end

--- Helper function to check if the given familiar is being controlled by The Siren boss.
---@param familiar EntityFamiliar
---@return boolean
function TSIL.Familiars.IsFamiliarStolenBySiren(familiar)
end

--- Helper function to convert the grid entity type found in a room XML file to the corresponding
--- grid entity type and variant normally used by the game. For example, a rock is represented as
--- 1000.0 in a room XML file, but `GridEntityType.GRID_ROCK` is equal to 2.
--- @param gridEntityXMLType GridEntityXMLType
--- @param gridEntityXMLVariant integer
--- @return {type : GridEntityType, variant : integer}
function TSIL.GridEntities.ConvertXMLGridEntityType(gridEntityXMLType, gridEntityXMLVariant)
end

--- Returns all the entities that are colliding with a given grid entity.
--- 
--- Note that this function won't work in the `POST_NEW_ROOM` callback, since
--- entities don't have collision yet.
--- @param gridEntity GridEntity
--- @return Entity[]
function TSIL.GridEntities.GetCollidingEntitiesWithGridEntity(gridEntity)
end

--- Returns a list with all grid entities in the room.
--- IsBlackList indicates whether the given grid entities should be the only ones added or the only ones not added.
--- @param isBlackList? boolean @Default: true
--- @param ... GridEntityType
--- @return GridEntity[]
function TSIL.GridEntities.GetGridEntities(isBlackList, ...)
end

--- Helper function to get all grid entities around a grid index, not including itself.
--- @param gridIndex GridEntity
--- @return GridEntity[]
function TSIL.GridEntities.GetSurroundingGridEntities(gridIndex)
end

--- Helper function to get the grid index of the top left wall.
--- @return integer
function TSIL.GridEntities.GetTopLeftWallGridIndex()
end

--- Helper function to get the top left wall grid entity.
--- @return GridEntity
function TSIL.GridEntities.GetTopLeftWall()
end

--- Helper function to check if a GridEntity is able to be broken with an explosion.
--- @param gridEntity GridEntity
--- @return boolean
function TSIL.GridEntities.IsGridEntityBreakableByExplosion(gridEntity)
end

--- Helper function to see if the given GridEntity is in its respective broken state.
--- 
--- Note that `GridEntityType.GRID_LOCK` will turn to being broken before the actual
--- collision is turned off.
--- @param gridEntity GridEntity
--- @return boolean
function TSIL.GridEntities.IsGridEntityBroken(gridEntity)
end

--- Helper function to remove a grid entity by providing the GridEntity or the grid index.
---
--- If removing a Devil or Angel Statue it'll also remove the associated effect.
--- @param gridEntityOrGridIndex GridEntity | integer
--- @param updateRoom boolean Whether or not to update the room after the grid entity is removed. If not, you won't be able to place another one until next frame. However doing so is expensive, so set this to false if you need to run this multiple times.
function TSIL.GridEntities.RemoveGridEntity(gridEntityOrGridIndex, updateRoom)
end

--- Helper function to remove all grid entities from a given list.
--- @param gridEntities GridEntity[]
--- @param updateRoom boolean Whether or not to update the room after the grid entity is removed. If not, you won't be able to place another one until next frame. However doing so is expensive, so set this to false if you need to run this multiple times.
function TSIL.GridEntities.RemoveGridEntities(gridEntities, updateRoom)
end

--- Helper function to spawn a grid entity.
---
--- Use this instead of `Isaac.GridSpawn` as it handles:
--- - Walls and pits collision
--- - Removing existing grid entities
--- - Allows you to use the grid index
--- @param gridEntityType GridEntityType
--- @param gridEntityVariant integer
--- @param gridIndexOrPosition Vector | integer
--- @param force boolean? @Default : true. Set this to true if you want to replace existing grid entities in the same tile.
--- @return GridEntity?
function TSIL.GridEntities.SpawnGridEntity(gridEntityType, gridEntityVariant, gridIndexOrPosition, force)
end

--- Helper function to spawn a void portal.
---
--- This is more complicated than just spawning a trapdoor with the appropriate variant, as
--- it won't have the correct graphics and it won't lead to The Void.
--- @param gridIndexOrPosition Vector | integer
--- @param force boolean? @Default : true. Set this to true if you want to replace existing grid entities in the same tile.
--- @return GridEntity?
function TSIL.GridEntities.SpawnVoidPortal(gridIndexOrPosition, force)
end

--- Helper function to spawn a giant poop.
--- 
--- Will return true if the poop has successfully spawned.
--- @param topLeftGridIndexOrPosition Vector | integer @Where the top left corner of the poop will be placed.
--- @param force boolean? @Default : true. Set this to true if you want to replace existing grid entities in the same tiles.
--- @return boolean
function TSIL.GridEntities.SpawnGigaPoop(topLeftGridIndexOrPosition, force)
end

--- Helper function to get every legal grid index for the current room.
--- If `onlyInRoom` is set to true it will only return those that are actually in the room,
--- accounting for L shaped and small rooms.
--- @param onlyInRoom boolean? @ Default : true
--- @return integer[]
function TSIL.GridIndexes.GetAllGridIndexes(onlyInRoom)
end

--- Helper function to get all the grid indexes between two others.
---
--- Note that the two grid indexes need to be in the same column or row.
---@param gridIndex1 integer
---@param gridIndex2 integer
---@param roomShape RoomShape
---@return integer[]
function TSIL.GridIndexes.GetGridIndexesBetween(gridIndex1, gridIndex2, roomShape)
end

--- Helper function to get all grid entities with type `GridEntityType.GRID_STAIRS` and the given variant.
---@param crawlSpaceVariant CrawlSpaceVariant? @ Default : -1. Which matches all variants.
---@return GridEntity[]
function TSIL.GridSpecific.GetCrawlSpaces(crawlSpaceVariant)
end

--- Helper function to get all grid entities with type `GridEntityType.GRID_PIT` and the given variant.
---@param pitVariant PitVariant? @ Default : -1. Which matches all variants.
---@return GridEntityPit[]
function TSIL.GridSpecific.GetPits(pitVariant)
end

--- Helper function to get all grid entities with type `GridEntityType.GRID_POOP` and the given variant.
---@param poopVariant PoopGridEntityVariant? @ Default : -1. Which matches all variants.
---@return GridEntityPoop[]
function TSIL.GridSpecific.GetPoops(poopVariant)
end

--- Helper function to get all grid entities with type `GridEntityType.GRID_PRESSURE_PLATE` and the given variant.
---@param pressurePlateVariant PressurePlateVariant? @ Default : -1. Which matches all variants.
---@return GridEntityPressurePlate[]
function TSIL.GridSpecific.GetPressurePlates(pressurePlateVariant)
end

--- Helper function to get all grid entities with type `GridEntityType.GRID_ROCK` and the given variant.
---@param rockVariant RockVariant? @ Default : -1. Which matches all variants.
---@return GridEntityRock[]
function TSIL.GridSpecific.GetRocks(rockVariant)
end

--- Helper function to get all grid entities with type `GridEntityType.GRID_SPIKES` and the given variant.
---@param spikesVariant integer? @ Default : -1. Which matches all variants.
---@return GridEntitySpikes[]
function TSIL.GridSpecific.GetSpikes(spikesVariant)
end

--- Helper function to get all grid entities with type `GridEntityType.GRID_TNT` and the given variant.
---@param TNTVariant integer? @ Default : -1. Which matches all variants.
---@return GridEntityTNT[]
function TSIL.GridSpecific.GetTNTs(TNTVariant)
end

--- Helper function to get all grid entities with type `GridEntityType.GRID_TELEPORTER` and the given variant.
---@param teleporterVariant integer? @ Default : -1. Which matches all variants.
---@return GridEntity[]
function TSIL.GridSpecific.GetTeleporters(teleporterVariant)
end

--- Helper function to get all grid entities with type `GridEntityType.GRID_TRAPDOOR` and the given variant.
---@param trapdoorVariant TrapdoorVariant? @ Default : -1. Which matches all variants.
---@return GridEntity[]
function TSIL.GridSpecific.GetTrapdoors(trapdoorVariant)
end

--- Helper function to spawn a door.
---@param doorVariant DoorVariant
---@param indexOrPosition integer | Vector
---@param force boolean? @ Default : true. Set this to true if you want to replace existing grid entities in the same tile.
---@return GridEntityDoor?
function TSIL.GridSpecific.SpawnDoor(doorVariant, indexOrPosition, force)
end

--- Helper function to spawn a pit.
---@param pitVariant PitVariant
---@param indexOrPosition integer | Vector
---@param force boolean? @ Default : true. Set this to true if you want to replace existing grid entities in the same tile.
---@return GridEntityPit?
function TSIL.GridSpecific.SpawnPit(pitVariant, indexOrPosition, force)
end

--- Helper function to spawn a poop.
---@param poopVariant PoopGridEntityVariant
---@param indexOrPosition integer | Vector
---@param force boolean? @ Default : true. Set this to true if you want to replace existing grid entities in the same tile.
---@return GridEntityPoop?
function TSIL.GridSpecific.SpawnPoop(poopVariant, indexOrPosition, force)
end

--- Helper function to spawn a pressure plate.
---@param pressurePlateVariant PressurePlateVariant
---@param indexOrPosition integer | Vector
---@param force boolean? @ Default : true. Set this to true if you want to replace existing grid entities in the same tile.
---@return GridEntityPressurePlate?
function TSIL.GridSpecific.SpawnPressurePlate(pressurePlateVariant, indexOrPosition, force)
end

--- Helper function to spawn a rock.
---@param rockVariant RockVariant
---@param indexOrPosition integer | Vector
---@param force boolean? @ Default : true. Set this to true if you want to replace existing grid entities in the same tile.
---@return GridEntityRock?
function TSIL.GridSpecific.SpawnRock(rockVariant, indexOrPosition, force)
end

--- Helper function to spawn a spike.
---@param spikeVariant integer
---@param indexOrPosition integer | Vector
---@param force boolean? @ Default : true. Set this to true if you want to replace existing grid entities in the same tile.
---@return GridEntitySpikes?
function TSIL.GridSpecific.SpawnSpikes(spikeVariant, indexOrPosition, force)
end

--- Helper function to spawn TNT.
---@param TNTVariant integer
---@param indexOrPosition integer | Vector
---@param force boolean? @ Default : true. Set this to true if you want to replace existing grid entities in the same tile.
---@return GridEntityTNT?
function TSIL.GridSpecific.SpawnTNT(TNTVariant, indexOrPosition, force)
end

--- Helper function to get all the values of the `ButtonAction` enum that correspond to movement.
---@return ButtonAction[]
function TSIL.Input.GetMoveActions()
end

--- Helper function to get all the values of the `ButtonAction` enum that correspond to shooting.
---@return ButtonAction[]
function TSIL.Input.GetShootActions()
end

--- Helper function to check if a given Button Action is being pressed in any controller.
---@param action ButtonAction
---@return boolean
function TSIL.Input.IsActionPressedOnAnyInput(action)
end

--- Helper function to check if a given Button Action is being triggered in any controller.
---@param action ButtonAction
---@return boolean
function TSIL.Input.IsActionTriggeredOnAnyInput(action)
end

--- Helper function to see if any of the given keys are being pressed in the keyboard.
---@param ... Keyboard
---@return boolean
function TSIL.Input.IsKeyboardPressed(...)
end

--- Helper function to get the modifier key that is being pressed in the keyboard
---
--- A modifier key is defined as shift, control, alt, or Windows.
---@return Keyboard? @ The modifier key that's being pressed, or nil if there are none.
function TSIL.Input.GetPressedModifier()
end

--- Helper function to get the string that would be typed if someone pressed the corresponding key.
---@param key Keyboard
---@param shiftPressed boolean
---@return string
function TSIL.Input.KeyboardToString(key, shiftPressed)
end

--- Helper function to check if a given Button Action corresponds to movement.
---@param buttonAction ButtonAction
---@return boolean
function TSIL.Input.IsMoveAction(buttonAction)
end

--- Helper function to check if a move action is being pressed in any controller.
---@return boolean
function TSIL.Input.IsMoveActionPressedOnAnyInput()
end

--- Helper function to check if a move action is being triggered in any controller.
---@return boolean
function TSIL.Input.IsMoveActionTriggeredOnAnyInput()
end

--- Helper function to check if a given Button Action corresponds to shooting.
---@param buttonAction ButtonAction
---@return boolean
function TSIL.Input.IsShootAction(buttonAction)
end

--- Helper function to check if a shoot action is being pressed in any controller.
---@return boolean
function TSIL.Input.IsShootActionPressedOnAnyInput()
end

--- Helper function to check if a shoot action is being triggered in any controller.
---@return boolean
function TSIL.Input.IsShootActionTriggeredOnAnyInput()
end

---Helper function to detect if a variable is of type `EntityKnife`
---@param variable unknown
---@return boolean
function TSIL.IsaacAPIClass.IsKnife(variable)
end

---Helper function to detect if a variable is of type `EntityLaser`
---@param variable unknown
---@return boolean
function TSIL.IsaacAPIClass.IsLaser(variable)
end

---Helper function to detect if a variable is of type `EntityNPC`
---@param variable unknown
---@return boolean
function TSIL.IsaacAPIClass.IsNPC(variable)
end

---Helper function to detect if a variable is of type `EntityPickup`
---@param variable unknown
---@return boolean
function TSIL.IsaacAPIClass.IsPickup(variable)
end

---Helper function to detect if a variable is of type `GridEntityPit`
---@param variable unknown
---@return boolean
function TSIL.IsaacAPIClass.IsPit(variable)
end

---Helper function to detect if a variable is of type `EntityPlayer`
---@param variable unknown
---@return boolean
function TSIL.IsaacAPIClass.IsPlayer(variable)
end

---Helper function to detect if a variable is of type `GridEntityPoop`
---@param variable unknown
---@return boolean
function TSIL.IsaacAPIClass.IsPoop(variable)
end

---Helper function to detect if a variable is of type `GridEntityPressurePlate`
---@param variable unknown
---@return boolean
function TSIL.IsaacAPIClass.IsPressurePlate(variable)
end

---Helper function to detect if a variable is of type `EntityProjectile`
---@param variable unknown
---@return boolean
function TSIL.IsaacAPIClass.IsProjectile(variable)
end

---Helper function to detect if a variable is of type `RNG`
---@param variable unknown
---@return boolean
function TSIL.IsaacAPIClass.IsRNG(variable)
end

---Helper function to detect if a variable is of type `GridEntityRock`
---@param variable unknown
---@return boolean
function TSIL.IsaacAPIClass.IsRock(variable)
end

---Helper function to detect if a variable is of type `GridEntitySpikes`
---@param variable unknown
---@return boolean
function TSIL.IsaacAPIClass.IsSpikes(variable)
end

---Helper function to detect if a variable is of type `EntityTear`
---@param variable unknown
---@return boolean
function TSIL.IsaacAPIClass.IsTear(variable)
end

---Helper function to detect if a variable is of type `GridEntityTNT`
---@param variable unknown
---@return boolean
function TSIL.IsaacAPIClass.IsTNT(variable)
end

---Helper function to get the name of a class from the Isaac API. This is contained within the
---"__type" metatable key.
---
---For example, a `Vector` class is has a name of "Vector".
---
---Returns nil if the object is not of type `userdata` or if the "__type" metatable key does
---not exist.
---
---In some cases, Isaac classes can be a read-only. If this is the case, the "__type" field will be
---prepended with "const ". This function will always strip this prefix, if it exists. For example,
---the class name returned for "const Vector" will be "Vector".
---@param object unknown
---@return string?
function TSIL.IsaacAPIClass.GetIsaacAPIClassName(object)
end

---Helper function to see if the given collectible is still present in the given item pool.
---
---If the collectible is non-offensive, any Tainted Losts will be temporarily changed to Isaac 
---and then changed back. (This is because Tainted Lost is not able to retrieve non-offensive 
---collectibles from item pools).
---
---Under the hood, this function works by using the ItemPool.AddRoomBlacklist method to blacklist
---every collectible except for the one provided.
---@param collectibleType CollectibleType
---@param itemPoolType ItemPoolType
---@return boolean
function TSIL.ItemPool.IsCollectibleInItemPool(collectibleType, itemPoolType)
end

---Converts a Lua table to a JSON string.
---
---In most cases, this function will be used for writing data to a "save#.dat" file. 
---If encoding fails, it will throw an error to prevent writing a blank string or corrupted
---data to a user's "save#.dat" file.
---
---Under the hood, this uses a custom JSON parser that was measured to be 11.8 times faster than the vanilla JSON parser.
---@param val any
---@return string
function TSIL.JSON.Encode(val)
end

---Converts a JSON string to a Lua table.
---
---In most cases, this function will be used for reading data from a "save#.dat" file.
---If decoding fails, it will return a blank Lua table instead of throwing an error.
---(This allows execution to continue in cases where users have no current save data or have
---manually removed their existing save data.)
---
---Under the hood, this uses a custom JSON parser that was measured to be 11.8 times faster than the vanilla JSON parser.
---@param str any
---@return unknown
function TSIL.JSON.Decode(str)
end

--- Helper function to get the name and the line number of the current calling function.
---
--- For this function to work properly, the "--luadebug" flag must be enabled. Otherwise, it will
--- always return undefined.
---@param levels number? Optional. The amount of levels to look backwards in the call stack. Default is 3 (because the first level is the function, the second level is the calling function, and the third level is the parent of the calling function.)
---@return string?
function TSIL.Log.GetParentFunctionDescription(levels)
end

--- Helper function to avoid typing out `Isaac.DebugString()`.
---
--- If you have the "--luadebug" launch flag turned on, then this
--- function will also prepend the function name and the line number before the string.
---@param message string
function TSIL.Log.Log(message)
end

---Helper function to get the corresponding coin amount from a `CoinSubType`. Returns 1 for modded sub-types.
---@param coinSubType CoinSubType
---@return integer
function TSIL.Pickups.GetCoinValue(coinSubType)
end

---Helper function to test if the provided pickup matches one of the various chest variants.
---@param pickup EntityPickup
---@return boolean
function TSIL.Pickups.IsChest(pickup)
end

---Helper function to get all of the red heart pickup entities in the room.
---@return EntityPickup[]
function TSIL.Pickups.GetRedHearts()
end

---Helper function to test if the provided pickup matches one of the various red heart sub types.
---@param pickup EntityPickup
---@return boolean
function TSIL.Pickups.IsRedHeart(pickup)
end

---Helper function to get all the batteries in the room.
---@param batterySubtype BatterySubType
---@return EntityPickup[]
function TSIL.PickupSpecific.GetBatteries(batterySubtype)
end

---Helper function to get all the bomb pickups in the room.
---@param bombSubtype? BombSubType
---@return EntityPickup[]
function TSIL.PickupSpecific.GetBombPickups(bombSubtype)
end

---Helper function to get all the cards in the room.
---@param cardType? Card
---@return EntityPickup[]
function TSIL.PickupSpecific.GetCards(cardType)
end

---Helper function to get all the coins in the room.
---@param coinSubtype? CoinSubType
---@return EntityPickup[]
function TSIL.PickupSpecific.GetCoins(coinSubtype)
end

---Helper function to get all the collectibles in the room.
---@param collectibleType? CollectibleType
---@return EntityPickup[]
function TSIL.PickupSpecific.GetCollectibles(collectibleType)
end

---Helper function to get all the hearts in the room.
---@param heartSubtype? HeartSubType
---@return EntityPickup[]
function TSIL.PickupSpecific.GetHearts(heartSubtype)
end

---Helper function to get all the keys in the room.
---@param keySubtype? KeySubType
---@return EntityPickup[]
function TSIL.PickupSpecific.GetKeys(keySubtype)
end

---Helper function to get all the pills in the room.
---@param pillColor? PillColor
---@return EntityPickup[]
function TSIL.PickupSpecific.GetPills(pillColor)
end

---Helper function to get all the sacks in the room.
---@param sackSubtype? SackSubType
---@return EntityPickup[]
function TSIL.PickupSpecific.GetSacks(sackSubtype)
end

---Helper function to get all the trinkets in the room.
---@param trinketType? TrinketType
---@return EntityPickup[]
function TSIL.PickupSpecific.GetTrinket(trinketType)
end

---Helper function to spawn a battery.
---@param batterySubtype BatterySubType
---@param position Vector
---@param velocity Vector?
---@param spawner Entity?
---@param seedOrRNG integer | RNG?
---@return EntityPickup
function TSIL.PickupSpecific.SpawnBattery(batterySubtype, position, velocity, spawner, seedOrRNG)
end

---Helper function to spawn a bomb pickup.
---@param bombSubtype BombSubType
---@param position Vector
---@param velocity Vector?
---@param spawner Entity?
---@param seedOrRNG integer | RNG?
---@return EntityPickup
function TSIL.PickupSpecific.SpawnBombPickup(bombSubtype, position, velocity, spawner, seedOrRNG)
end

---Helper function to spawn a card.
---@param cardType Card
---@param position Vector
---@param velocity Vector?
---@param spawner Entity?
---@param seedOrRNG integer | RNG?
---@return EntityPickup
function TSIL.PickupSpecific.SpawnCard(cardType, position, velocity, spawner, seedOrRNG)
end

---Helper function to spawn a coin.
---@param coinSubtype CoinSubType
---@param position Vector
---@param velocity Vector?
---@param spawner Entity?
---@param seedOrRNG integer | RNG?
---@return EntityPickup
function TSIL.PickupSpecific.SpawnCoin(coinSubtype, position, velocity, spawner, seedOrRNG)
end

---Helper function to spawn a heart.
---@param heartSubtype HeartSubType
---@param position Vector
---@param velocity Vector?
---@param spawner Entity?
---@param seedOrRNG integer | RNG?
---@return EntityPickup
function TSIL.PickupSpecific.SpawnHeart(heartSubtype, position, velocity, spawner, seedOrRNG)
end

---Helper function to spawn a key.
---@param keySubtype KeySubType
---@param position Vector
---@param velocity Vector?
---@param spawner Entity?
---@param seedOrRNG integer | RNG?
---@return EntityPickup
function TSIL.PickupSpecific.SpawnKey(keySubtype, position, velocity, spawner, seedOrRNG)
end

---Helper function to spawn a pill.
---@param pillColor PillColor
---@param position Vector
---@param velocity Vector?
---@param spawner Entity?
---@param seedOrRNG integer | RNG?
---@return EntityPickup
function TSIL.PickupSpecific.SpawnPill(pillColor, position, velocity, spawner, seedOrRNG)
end

---Helper function to spawn a sack.
---@param sackSubtype SackSubType
---@param position Vector
---@param velocity Vector?
---@param spawner Entity?
---@param seedOrRNG integer | RNG?
---@return EntityPickup
function TSIL.PickupSpecific.SpawnSack(sackSubtype, position, velocity, spawner, seedOrRNG)
end

---Helper function to spawn a trinket.
---@param trinketType TrinketType
---@param position Vector
---@param velocity Vector?
---@param spawner Entity?
---@param seedOrRNG integer | RNG?
---@return EntityPickup
function TSIL.PickupSpecific.SpawnTrinket(trinketType, position, velocity, spawner, seedOrRNG)
end

--- Helper function to get the corresponding pill effect a pill effect would be
--- converted into after picking up PHD.
---
--- If the pill wouldn't transform, it returns the same pill effect.
---@param pillEffect PillEffect
---@return PillEffect
function TSIL.Pills.GetPHDPillEffect(pillEffect)
end

--- Helper function to get the corresponding pill effect a pill effect would be
--- converted into after picking up False PHD.
---
--- If the pill wouldn't transform, it returns the same pill effect.
---@param pillEffect PillEffect
---@return PillEffect
function TSIL.Pills.GetFalsePHDPillEffect(pillEffect)
end

--- Helper function to get the name of a given pill effect.
--- For modded pill effects it returns the name set in the xml.
---@param pillEffect PillEffect
---@return string
function TSIL.Pills.GetPillEffectName(pillEffect)
end

--- Helper function to get the `PillEffectType` of a given pill effect.
---
--- Due to API limitations, it'll returns `PillEffectType.MODDED` for modded pills.
---@param pillEffect PillEffect
---@return PillEffectType
function TSIL.Pills.GetPillEffectType(pillEffect)
end

--- Helper function to get the corresponding horse pill color from a normal pill color
---@param pillColor PillColor
---@return PillColor
function TSIL.Pills.GetHorsePillCollor(pillColor)
end

--- Helper function to get the corresponding normal pill color from a horse pill color
---@param pillColor PillColor
---@return PillColor
function TSIL.Pills.GetNormalPillColorFromHorsePill(pillColor)
end

--- Helper function to check if a pill color corresponds to a horse pill.
---@param pillColor PillColor
---@return boolean
function TSIL.Pills.IsHorsePill(pillColor)
end

--- Returns a list of all players.
--- @param ignoreCoopBabies? boolean @default: true
--- @return EntityPlayer[]
function TSIL.Players.GetPlayers(ignoreCoopBabies)
end

--- Returns the n closest players to a certain point.
--- The players are ordered by their distance.
--- @param center Vector
--- @param numberOfPlayers? integer @default : 1
--- @return EntityPlayer[]
function TSIL.Players.GetClosestPlayers(center, numberOfPlayers)
end

--- Returns a list of all players that have a certain item
--- @param collectibleId CollectibleType
--- @return EntityPlayer[]
function TSIL.Players.GetPlayersByCollectible(collectibleId)
end

--- Returns all the players that have a certain trinket
--- @param trinketId TrinketType
--- @return EntityPlayer[]
function TSIL.Players.GetPlayersByTrinket(trinketId)
end

--- Returns all the players of a given type.
---@param playerType PlayerType
---@return EntityPlayer[]
function TSIL.Players.GetPlayersOfType(playerType)
end

--- Returns true if at least one player has the given item.
--- @param collectibleId CollectibleType
--- @param ignoreModifiers boolean? @Default : false
--- @return boolean
function TSIL.Players.DoesAnyPlayerHasItem(collectibleId, ignoreModifiers)
end

--- Returns true if at least one player has the given trinket.
--- @param trinketId TrinketType
--- @param ignoreModifiers boolean? @Default : false
--- @return boolean
function TSIL.Players.DoesAnyPlayerHasTrinket(trinketId, ignoreModifiers)
end

--- Returns a list of all the items/gulped trinkets (things that appear on the extra HUD) ordered by the time they were collected.
--- This method is not perfect and will fail if the player rerolls all of their items or a mod gives several items in the same frame.
--- @param player EntityPlayer
--- @param inventoryTypeFilter? InventoryType
--- @return InventoryObject[]
function TSIL.Players.GetPlayerInventory(player, inventoryTypeFilter)
end

--- Returns a given player's index. Useful for storing unique data per player.
--- @param player EntityPlayer
--- @return integer
function TSIL.Players.GetPlayerIndex(player)
end

--- Returns a player given its index.
--- @param playerIndex integer
--- @return EntityPlayer?
function TSIL.Players.GetPlayerByIndex(playerIndex)
end

--- Returns wether the given form of tainted lazarus is the active one.
--- If the given player is not tainted lazarus, it'll always return false.
--- 
--- Accounts for when the player has Birthright.
--- @param player EntityPlayer
--- @return boolean
function TSIL.Players.IsActiveTaintedLazForm(player)
end

--- Gives the player an smelted trinket without changing the player's current held trinkets.
--- @param player EntityPlayer
--- @param trinketId TrinketType
function TSIL.Players.AddSmeltedTrinket(player, trinketId)
end

--- Returns the number of trinkets a player has smelted.
--- Won't count the trinkets they're currently holding.
--- @param player EntityPlayer
--- @param trinket TrinketType
--- @return integer
function TSIL.Players.GetSmeltedTrinketMultiplier(player, trinket)
end

---This returns a random float between 0 and 1. It is inclusive on the low end, but exclusive on the
---high end. (This is because the `RNG.RandomFloat` method will never return a value of exactly 1.)
---@param seedOrRNG integer | RNG? Optional. The `Seed` or `RNG` object to use. If an `RNG` object is provided, the `RNG.Next` method will be called. Default is `TSIL.RNG.GetRandomSeed()`.
---@return number
function TSIL.Random.GetRandom(seedOrRNG)
end

---This returns a random float between min and max.
---@param min number The lower bound for the random number (inclusive).
---@param max number The upper bound for the random number (exclusive)
---@param seedOrRNG integer | RNG? Optional. The `Seed` or `RNG` object to use. If an `RNG` object is provided, the `RNG.Next` method will be called. Default is `TSIL.RNG.GetRandomSeed()`.
---@return number
function TSIL.Random.GetRandomFloat(min, max, seedOrRNG)
end

---This returns a random integer between min and max. It is inclusive on both ends.
---Note that this function will run the `Next` method on the `RNG` object before returning the
---random number.
---@param min integer The lower bound for the random number (inclusive).
---@param max integer The upper bound for the random number (inclusive)
---@param seedOrRNG number | RNG? Optional. The `Seed` or `RNG` object to use. If an `RNG` object is provided, the `RNG.Next` method will be called. Default is `TSIL.RNG.GetRandomSeed()`.
---@param exceptions integer[]? Optional. An array of elements that will be skipped over when getting the random integer. For example, a min of 1, a max of 4, and an exceptions array of `[2]` woudl cause the function to return either 1, 3, or 4. Default is an empty array.
---@return integer
function TSIL.Random.GetRandomInt(min, max, seedOrRNG, exceptions)
end

--- Returns n randomly selected elements from a table.
--- @generic T any
--- @param toChoose T[]
--- @param numberOfElements? integer @Default: 1
--- @param seedOrRNG integer | RNG? Optional. The `Seed` or `RNG` object to use. If an `RNG` object is provided, the `RNG.Next` method will be called. Default is `TSIL.RNG.GetRandomSeed()`.
--- @return T[]
function TSIL.Utils.Random.GetRandomElementsFromTable(toChoose, numberOfElements, seedOrRNG)
end

--- Returns a random value from a weighted list of possibilities.
--- Each choice must be given as a pair of chance and value.
--- 
--- `{chance = x, value = y}`
--- @generic T any
--- @param seedOrRNG integer | RNG
--- @param ... {chance : integer, value : T}
--- @return T
function TSIL.Utils.Random.GetRandomElementFromWeightedList(seedOrRNG, ...)
end

---Copies an `RNG` object
---@param rng RNG
---@return RNG
function TSIL.RNG.CopyRNG(rng)
end

---Helper function to get a random `Seed` value to be used in spawning entities and so on. Use this
---instead of calling the `Random` function directly since that can return a value of 0 and crash
---the game.
---@return integer
function TSIL.RNG.GetRandomSeed()
end

---Helper function to initialize an RNG object using Blade's recommended shift index.
---@param seed integer? The seed to initialize it with. Default is `TSIL.RNG.GetRandomSeed`
---@return RNG
function TSIL.RNG.NewRNG(seed)
end

--- Helper function to set a seed to an RNG object using Blade's recommended shift index.
---@param rng RNG
---@param seed integer
function TSIL.RNG.SetSeed(rng, seed)
end

---Helper function to remove all naturally spawning entities and grid entities from a room.
---Notably, this will not remove players, tears, familiars, lasers, knives, projectiles,
---blacklisted NPCs such as Dark Esau, charmed NPCs, friendly NPCs, persistent NPCs, most effects,
---doors, and walls.
function TSIL.Rooms.EmptyRoom()
end

--- Helper function to get the width of the grid in a given room shape.
---@param shape RoomShape
---@return integer
function TSIL.Rooms.GetRoomShapeGridWidth(shape)
end

--- Helper function to check if a grid index is valid in a certain room shape.
--- 
--- Doesn't account for being out of bounds (less than 0 or greater than the grid size).
--- For that use `TSIL.GridEntities.IsGridIndexInRoom`
--- @param gridIndex integer
--- @param roomShape RoomShape
--- @return boolean
function TSIL.Rooms.IsGridIndexInRoomShape(gridIndex, roomShape)
end

--- Helper function to check if a grid index is inside a room, including walls.
--- Accounts for room shape.
--- @param gridIndex integer
--- @return boolean
function TSIL.Rooms.IsGridIndexInRoom(gridIndex)
end

--- Helper function to trigger a room update without affecting entity positions or velocities.
function TSIL.Rooms.UpdateRoom()
end

--- Adds a variable to the save manager.
--- The variable name must be unique within your mod.
--- @param mod table
--- @param variableName string
--- @param value any
--- @param persistenceMode VariablePersistenceMode
function TSIL.SaveManager.AddPersistentVariable(mod, variableName, value, persistenceMode)
end

--- Gets a variable from the save manager.
--- @param mod table
--- @param variableName string
--- @return any
function TSIL.SaveManager.GetPersistentVariable(mod, variableName)
end

--- Removes a variable from the save manager.
--- @param mod table
--- @param variableName string
function TSIL.SaveManager.RemovePersistentVariable(mod, variableName)
end

--- Resets a variable to its default value in the save manager.
--- @param mod table
--- @param variableName string
function TSIL.SaveManager.ResetPersistentVariable(mod, variableName)
end

--- Sets a variable from the save manager.
--- @param mod table
--- @param variableName string
--- @param newValue any
--- @param overrideType? boolean @default: false
function TSIL.SaveManager.SetPersistentVariable(mod, variableName, newValue, overrideType)
end

---Creates a new shockwave with the given params.
---
---Returns the spawned shockwave, if it can't spawn it, returns nil.
---@param source Entity
---@param position Vector
---@param customShockwaveParams CustomShockwaveParams
---@return Entity?
function TSIL.ShockWaves.CreateShockwave(source, position, customShockwaveParams)
end

---Creates a shockwave ring with the given properties.
---
---Returns the spawned shockwaves. If multiple shockwaves are set to spawn, returns only
---the shockwaves spawned in the first ring.
---@param source Entity
---@param center Vector
---@param radius number
---@param customShockwaveParams CustomShockwaveParams
---@param direction Vector? @Default : Vector(0, -1)
---@param angleWidth number? @Default : 360
---@param spacing number? @Default : 35 * customShockwaveParams.Size
---@param numRings integer? @Default : 1
---@param ringSpacing integer? @Default : 35 * customShockwaveParams.Size
---@param ringDelay integer? @Default : 5
---@return Entity[]
function TSIL.ShockWaves.CreateShockwaveRing(source, center, radius, customShockwaveParams, direction, angleWidth, spacing, numRings, ringSpacing, ringDelay)
end

---Creates a shockwave line with the given properties.
---
---Returns only the first shockwave spawned.
---@param source Entity
---@param center Vector
---@param direction Vector
---@param customShockwaveParams CustomShockwaveParams
---@param spacing number? @Default : 35 * customShockwaveParams.Size
---@param delay integer? @Default : 1
---@param numShockwaves integer? @Default : -1 Which makes the line travel until it hits an obstacle it can't break
---@return Entity?
function TSIL.ShockWaves.CreateShockwaveLine(source, center, direction, customShockwaveParams, spacing, delay, numShockwaves)
end

---Creates a shockwave line with the given properties. Each shockwave is spawned with a random offset.
---
---Returns only the first shockwave spawned.
---@param source Entity
---@param center Vector
---@param direction Vector
---@param customShockwaveParams CustomShockwaveParams
---@param seedOrRNG integer | RNG? Optional. The `Seed` or `RNG` object to use. If an `RNG` object is provided, the `RNG.Next` method will be called. Default is `TSIL.RNG.GetRandomSeed()`.
---@param randomOffset integer? @Default : 60
---@param spacing number? @Default : 35 * customShockwaveParams.Size
---@param delay integer? @Default : 1
---@param numShockwaves integer? @Default : -1 Which makes the line travel until it hits an obstacle it can't break
---@return Entity?
function TSIL.ShockWaves.CreateShockwaveRandomLine(source, center, direction, customShockwaveParams, seedOrRNG, randomOffset, spacing, delay, numShockwaves)
end

---Helper function to check whether a given entity is a custom shockwave.
---@param entity Entity
---@return boolean
function TSIL.ShockWaves.IsCustomShockwave(entity)
end

---Helper function to get a custom shockwave's data.
---@param entity Entity
---@return table?
function TSIL.ShockWaves.IsCustomShockwave(entity)
end

---Creates a new `CustomShockwaveParams` object.
---@return CustomShockwaveParams
function TSIL.ShockWaves.CustomShockwaveParams()
end

--- Helper function to check if two texels on a sprite are equivalent to each other.
--- @param sprite1 Sprite
--- @param sprite2 Sprite
--- @param position Vector
--- @param layer integer
--- @return boolean
function TSIL.Sprites.TexelEquals(sprite1, sprite2, position, layer)
end

--- Helper function to check if two sprite layers have the same sprite sheet by using the
--- `Sprite.GetTexel` method.
---
--- Since checking every single texel in the entire sprite is very expensive, this function
--- requires you to specify the range of texels to check.
--- @param sprite1 Sprite
--- @param sprite2 Sprite
--- @param layer integer
--- @param xStart integer
--- @param xFinish integer
--- @param xIncrement integer
--- @param yStart integer
--- @param yFinish integer
--- @param yIncrement integer
--- @return boolean
function TSIL.Sprites.SpriteEquals(sprite1, sprite2, layer, xStart, xFinish, xIncrement, yStart, yFinish, yIncrement)
end

--- Check https://easings.net/#easeInSine
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInSine(x)
end

--- Check https://easings.net/#easeOutSine
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseOutSine(x)
end

--- Check https://easings.net/#easeInOutSine
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInOutSine(x)
end

--- Check https://easings.net/#easeInQuad
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInQuad(x)
end

--- Check https://easings.net/#easeOutQuad
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseOutQuad(x)
end

--- Check https://easings.net/#easeInOutQuad
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInOutQuad(x)
end

--- Check https://easings.net/#easeInCubic
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInCubic(x)
end

--- Check https://easings.net/#easeOutCubic
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseOutCubic(x)
end

--- Check https://easings.net/#easeInOutCubic
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInOutCubic(x)
end

--- Check https://easings.net/#easeInQuart
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInQuart(x)
end

--- Check https://easings.net/#easeOutQuart
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseOutQuart(x)
end

--- Check https://easings.net/#easeInOutQuart
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInOutQuart(x)
end

--- Check https://easings.net/#easeInQuint
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInQuint(x)
end

--- Check https://easings.net/#easeOutQuint
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseOutQuint(x)
end

--- Check https://easings.net/#easeInOutQuint
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInOutQuint(x)
end

--- Check https://easings.net/#easeInExpo
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInExpo(x)
end

--- Check https://easings.net/#easeOutExpo
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseOutExpo(x)
end

--- Check https://easings.net/#easeInOutExpo
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInOutExpo(x)
end

--- Check https://easings.net/#easeInCirc
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInCirc(x)
end

--- Check https://easings.net/#easeOutCirc
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseOutCirc(x)
end

--- Check https://easings.net/#easeInOutCirc
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInOutCirc(x)
end

--- Check https://easings.net/#easeInBack
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInBack(x)
end

--- Check https://easings.net/#easeOutBack
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseOutBack(x)
end

--- Check https://easings.net/#easeInOutBack
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInOutBack(x)
end

--- Check https://easings.net/#easeInElastic
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInElastic(x)
end

--- Check https://easings.net/#easeOutElastic
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseOutElastic(x)
end

--- Check https://easings.net/#easeInOutElastic
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInOutElastic(x)
end

--- Check https://easings.net/#easeInBounce
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInBounce(x)
end

--- Check https://easings.net/#easeOutBounce
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseOutBounce(x)
end

--- Check https://easings.net/#easeInOutBounce
--- @param x number
--- @return number
function TSIL.Utils.Easings.EaseInOutBounce(x)
end

--- Adds the given flag to another one.
--- @param flags integer
--- @param ... integer
--- @return integer
function TSIL.Utils.Flags.AddFlags(flags, ...)
end

--- Checks whether a given flag has all of the other given flags.
--- @param flags integer
--- @param ... integer
--- @return boolean
function TSIL.Utils.Flags.HasFlags(flags, ...)
end

--- Removes the given flags from another one.
--- @param flags integer
--- @param ... integer
--- @return integer
function TSIL.Utils.Flags.RemoveFlags(flags, ...)
end

--- Runs a given function on the next `POST_NEW_LEVEL` callback.
--- @param funct function
--- @param ... any
function TSIL.Utils.Functions.RunNextLevel(funct, ...)
end

--- Runs a given function on the next `POST_NEW_ROOM` callback.
--- @param funct function
--- @param ... any
function TSIL.Utils.Functions.RunNextRoom(funct, ...)
end

--- Runs a function in a given number of frames.
--- @param funct function
--- @param frames integer
--- @param ... any
function TSIL.Utils.Functions.RunInFrames(funct, frames, ...)
end

--- Returns whether a given rectangle is intersecting a given circle.
--- @param RectPos Vector Center of the rectangle
--- @param RectSize Vector
--- @param CirclePos Vector Center of the circle
--- @param CircleSize number
--- @return boolean
function TSIL.Utils.Math.IsCircleIntersectingWithRectangle(RectPos, RectSize, CirclePos, CircleSize)
end

--- Helper function to clamp a number into a range.
--- @param a number
--- @param min number
--- @param max number
--- @return number
function TSIL.Utils.Math.Clamp(a, min, max)
end

--- Helper function to lineally interpolate between two numbers.
--- @param a number
--- @param b number
--- @param t number
--- @return number
function TSIL.Utils.Math.Lerp(a, b, t)
end

--- Rounds a number to the closest number of decimal places given.
--- 
--- Defaults to rounding to the nearest integer.
--- @param n number
--- @param decimalPlaces integer? @default : 0
--- @return number
function TSIL.Utils.Math.Round(n, decimalPlaces)
end

---Constructs a dictionary from a table. Note that the value of each key is set to true.
---@generic T
---@param oldTable T[]
---@return table<T, boolean>
function TSIL.Utils.Tables.ConstructDictionaryFromTable(oldTable)
end

--- Returns a safe copy of a table.
--- 
--- It copies the tables inside it recursively.
--- @param toCopy table
--- @return table
function TSIL.Utils.Tables.Copy(toCopy)
end

--- Counts how many elements are on a given table that match a predicate.
--- 
--- If no predicate is given, it'll count all the elements.
--- @generic T:any
--- @param toCount T[]
--- @param predicate fun(key: integer | string, value: T): boolean @default foo() -> true
--- @return integer
function TSIL.Utils.Tables.Count(toCount, predicate)
end

--- Helper function for determining if two arrays contain the exact same elements. 
--- @generic T: any
--- @param table1 T[]
--- @param table2 T[]
--- @return boolean
function TSIL.Utils.Tables.Equals(table1, table2)
end

--- Filters a table given a predicate
--- @generic T:any
--- @param toFilter T[]
--- @param predicate fun(key: integer | string, value: T): boolean
--- @return T[]
function TSIL.Utils.Tables.Filter(toFilter, predicate)
end

--- Returns the first value of a table that matches a given predicate.
--- 
--- If it doesn't find any, it returns nil.
--- @generic T : any
--- @param toFind T[]
--- @param predicate fun(key: integer | string, value: T): boolean
--- @return T?
function TSIL.Utils.Tables.FindFirst(toFind, predicate)
end

--- Executes a function for each key-value pair of a table
--- @generic T:any
--- @param toIterate T[] 
--- @param funct fun(index: string|integer, value:T)
function TSIL.Utils.Tables.ForEach(toIterate, funct)
end

--- Returns whether a given element is on a table
--- @generic T:any
--- @param list T[]
--- @param element T
--- @return boolean
function TSIL.Utils.Tables.IsIn(list, element)
end

--- Creates a new table where each element is the result of applying
--- a given function to each element of the provided list.
---@generic T any
---@generic S any
---@param list T[]
---@param funct fun(index: string|integer, value:T) : S
---@return S[]
function TSIL.Utils.Tables.Map(list, funct)
end

--- Shallow copies and removes the specified element(s) from the table. Returns the copied table. If
--- the specified element(s) are not found in the table, it will simply return a shallow copy of the
--- table.
--- 
--- This function is variadic, meaning that you can specify N arguments to remove N elements.
--- 
--- If there is more than one matching element in the table, this function will only remove the first
--- matching element. If you want to remove all of the elements, use the `RemoveAll` function
--- instead.
--- @generic T 
--- @param originalTable T[]
--- @vararg any
--- @return T[]
function TSIL.Utils.Tables.Remove(originalTable, ...)
end

--- Shallow copies and removes the specified element(s) from the table. Returns the copied table. If
--- the specified element(s) are not found in the table, it will simply return a shallow copy of the
--- table.
--- 
--- This function is variadic, meaning that you can specify N arguments to remove N elements.
--- 
--- If there is more than one matching element in the table, this function will remove every matching
--- element. If you want to only remove the first matching element, use the `Remove` function instead.
--- @generic T 
--- @param originalTable T[]
--- @vararg any
--- @return T[]
function TSIL.Utils.Tables.RemoveAll(originalTable, ...)
end

--- Removes all of the specified element(s) from the table. If the specified element(s) are not found
--- in the table, this function will do nothing.
--- 
--- This function is variadic, meaning that you can specify N arguments to remove N elements.
--- 
--- If there is more than one matching element in the table, this function will remove every matching
--- element. If you want to only remove the first matching element, use the `RemoveInPlace`
--- function instead.
--- @generic T 
--- @param originalTable T[]
--- @vararg any
--- @return boolean # True if one or more elements were removed, false otherwise. 
function TSIL.Utils.Tables.RemoveAllInPlace(originalTable, ...)
end

--- Removes the specified element(s) from the table. If the specified element(s) are not found in the
--- table, this function will do nothing.
--- 
--- This function is variadic, meaning that you can specify N arguments to remove N elements.
---  
--- If there is more than one matching element in the table, this function will only remove the first
--- matching element. If you want to remove all of the elements, use the `RemoveAllInPlace` function
--- instead.
--- @param originalTable any
--- @vararg any
--- @return boolean # True if one or more elements were removed, false otherwise. 
function TSIL.Utils.Tables.RemoveInPlace(originalTable, ...)
end

