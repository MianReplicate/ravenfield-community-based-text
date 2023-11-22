-- Register the behaviour
behaviour("LinePack")

function LinePack:Start()
	self.version = 1

	self.onMatchBeginLines = {}
	self.onVictoryLines = {}
	self.onDefeatLines = {}
	self.onKillEnemyLines = {}
	self.onKillFriendlyLines = {}
	self.onKilledByEnemyLines = {}
	self.onKilledByFriendlyLines = {}

	self:ReadDataContainers()

	local targetObject = self.gameObject.Find("CBT")
	if targetObject == nil then
		print("Community Based Text mutator not found!")
		return
	end

	local cbt = targetObject.GetComponent(ScriptedBehaviour)
	cbt.self:AddLinePack(self)
end

function LinePack:ReadDataContainers()
	self.onMatchBeginLines = self.targets.onMatchBeginLines.GetStringArray("line")
	self.onVictoryLines = self.targets.onVictoryLines.GetStringArray("line")
	self.onDefeatLines = self.targets.onDefeatLines.GetStringArray("line")
	self.onKillEnemyLines = self.targets.onKillEnemyLines.GetStringArray("line")
	self.onKillFriendlyLines = self.targets.onKillFriendlyLines.GetStringArray("line")
	self.onKilledByEnemyLines = self.targets.onKilledByEnemyLines.GetStringArray("line")
	self.onKilledByFriendlyLines = self.targets.onKilledByFriendlyLines.GetStringArray("line")
end
