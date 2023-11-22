-- Register the behaviour
behaviour("CommunityBasedText")

get_team_color = {[Team.Blue] = "#009BFF", [Team.Red] = "#F64B00"}
opposite_team = {[Team.Blue] = Team.Red, [Team.Red] = Team.Blue}

function CommunityBasedText:Awake()
	self.gameObject.name = "CBT"

	self.onMatchBeginLines = {}
	self.onVictoryLines = {}
	self.onDefeatLines = {}
	self.onKillEnemyLines = {}
	self.onKillFriendlyLines = {}
	self.onKilledByEnemyLines = {}
	self.onKilledByFriendlyLines = {}

	self.onKillEnemyChance = 0.5
	self.onKillFriendlyChance = 0.5
	self.onKilledByEnemyChance = 0.5
	self.onKilledByFriendlyChance = 0.5

	self.maxLines = 10
	self.lines = {}
	for i=1,self.maxLines do
		self.lines[i] = ""
	end

	self:UpdateText()

	GameEvents.onMatchEnd.AddListener(self,"OnMatchEnd")
	GameEvents.onActorDiedInfo.AddListener(self,"OnActorDied")
	GameEvents.onActorSpawn.AddListener(self,"OnActorSpawn")

	self.hasSpawned = false
end

function CommunityBasedText:Update()
	if Input.GetKeyDown(KeyCode.T) then
		local team = Player.actor.team

		self.script.StartCoroutine(self:SequentialTextSequence(team, self.onVictoryLines))
		self.script.StartCoroutine(self:SequentialTextSequence(opposite_team[team], self.onDefeatLines))
	end
end

function CommunityBasedText:OnActorDied(actor, damageInfo, isSilentKill)
	if isSilentKill then return end
	if damageInfo.sourceActor == nil then return end

	if not actor.isPlayer then
		local line = ""
		local messages = {}
		if actor.team ~= damageInfo.sourceActor.team and RandomChance(self.onKilledByEnemyChance) then
			self:GetAndPushLine(actor,damageInfo.sourceActor,self.onKilledByEnemyLines)
		elseif actor.team == damageInfo.sourceActor.team and RandomChance(self.onKilledByFriendlyChance) then
			self:GetAndPushLine(actor,damageInfo.sourceActor,self.onKilledByFriendlyLines)
		end
	end

	if not damageInfo.sourceActor.isPlayer then
		local line = ""
		local messages = {}
		if actor.team ~= damageInfo.sourceActor.team and RandomChance(self.onKillEnemyChance) then
			self:GetAndPushLine(damageInfo.sourceActor,actor,self.onKillEnemyLines)
		elseif actor.team == damageInfo.sourceActor.team and RandomChance(self.onKillFriendlyChance) then
			self:GetAndPushLine(damageInfo.sourceActor,actor,self.onKillFriendlyLines)
		end
		
	end
end

function CommunityBasedText:OnMatchEnd(team)
	self.script.StartCoroutine(self:SequentialTextSequence(team, self.onVictoryLines))
	self.script.StartCoroutine(self:SequentialTextSequence(opposite_team[team], self.onDefeatLines))
end

function CommunityBasedText:OnActorSpawn(actor)
	if(actor == Player.actor) and not self.hasSpawned then
		self.hasSpawned = true
		self.script.StartCoroutine(self:SequentialTextSequence(Team.Blue, self.onMatchBeginLines))
		self.script.StartCoroutine(self:SequentialTextSequence(Team.Red, self.onMatchBeginLines))
	end
end


function CommunityBasedText:GetAndPushLine(speaker, target, messages)
	local line = self:GetLine(speaker, target, messages)
	if line ~= "" then
		self:PushLine(line)
	end
end

function CommunityBasedText:GetLine(speaker, target, messages)
	if speaker == nil then return "" end
	if messages == nil then return "" end
	if #messages < 1 then return "" end

	local line = messages[math.random(#messages)]

	if target then
		line = string.format(line, target.name)
	end

	local speakerName = self:FormatActorName(speaker)

	return speakerName .. ": " .. line
end

function CommunityBasedText:PushLine(line)
	for i=1,self.maxLines-1 do
		self.lines[i] = self.lines[i+1]
	end
	self.lines[self.maxLines] = line

	self:UpdateText()
end

function CommunityBasedText:UpdateText()
	local finalString = ""

	for i=1,self.maxLines do
		if self.lines[i] ~= "" then
			finalString = finalString .. self.lines[i] .. "\n"
		end
	end

	self.targets.ChatBox.text = finalString
end

function CommunityBasedText:AddLinePack(linePack)
	for i, line in ipairs(linePack.onMatchBeginLines) do
		table.insert(self.onMatchBeginLines, line)
	end

	for i, line in ipairs(linePack.onVictoryLines) do
		table.insert(self.onVictoryLines, line)
	end

	for i, line in ipairs(linePack.onDefeatLines) do
		table.insert(self.onDefeatLines, line)
	end

	for i, line in ipairs(linePack.onKillEnemyLines) do
		table.insert(self.onKillEnemyLines, line)
	end

	for i, line in ipairs(linePack.onKillFriendlyLines) do
		table.insert(self.onKillFriendlyLines, line)
	end

	for i, line in ipairs(linePack.onKilledByEnemyLines) do
		table.insert(self.onKilledByEnemyLines, line)
	end

	for i, line in ipairs(linePack.onKilledByFriendlyLines) do
		table.insert(self.onKilledByFriendlyLines, line)
	end
end


function CommunityBasedText:PushMessageAfterDelay(from, message, delay)
	coroutine.yield(WaitForSeconds(delay))
	self:PushMessage(from, message)
end

function CommunityBasedText:FormatActorName(actor)
	return "<color=" .. get_team_color[actor.team] .. ">" .. actor.name .. "</color>"
end

function RandomChance(chance)
	return math.random() < chance
end

function CommunityBasedText:SequentialTextSequence(team, messages)
	return function()
		local baseInterval = 0.5
		local intervalVariance = 0.5

		local interval = baseInterval + math.random() * intervalVariance
		local intervalTimer = 0 

		for i, actor in ipairs(ActorManager.GetActorsOnTeam(team)) do
			if not actor.isPlayer then
				while(intervalTimer < interval) do
					intervalTimer = intervalTimer + Time.deltaTime
					coroutine.yield(nil)
				end
				intervalTimer = 0
				self:GetAndPushLine(actor, nil, messages)
			end
			coroutine.yield(nil)
		end
	end
end