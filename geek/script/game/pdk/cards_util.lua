local pb = require "pb_files"
local log = require "log"

local cards_util = {}

local PDK_CARD_TYPE = {
	SINGLE = pb.enum("PDK_CARD_TYPE", "SINGLE"),
	DOUBLE = pb.enum("PDK_CARD_TYPE", "DOUBLE"),
	THREE = pb.enum("PDK_CARD_TYPE", "THREE"),
	THREE_WITH_ONE = pb.enum("PDK_CARD_TYPE", "THREE_WITH_ONE"),
	THREE_WITH_TWO = pb.enum("PDK_CARD_TYPE", "THREE_WITH_TWO"),
	FOUR_WITH_SINGLE = pb.enum("PDK_CARD_TYPE", "FOUR_WITH_SINGLE"),
	FOUR_WITH_DOUBLE = pb.enum("PDK_CARD_TYPE", "FOUR_WITH_DOUBLE"),
	SINGLE_LINE = pb.enum("PDK_CARD_TYPE", "SINGLE_LINE"),
	DOUBLE_LINE = pb.enum("PDK_CARD_TYPE", "DOUBLE_LINE"),
	PLANE = pb.enum("PDK_CARD_TYPE", "PLANE"),
	PLANE_WITH_ONE = pb.enum("PDK_CARD_TYPE", "PLANE_WITH_ONE"),
	PLANE_WITH_TWO = pb.enum("PDK_CARD_TYPE", "PLANE_WITH_TWO"),
	BOMB = pb.enum("PDK_CARD_TYPE", "BOMB"),
	FOUR_WITH_THREE = pb.enum("PDK_CARD_TYPE", "FOUR_WITH_THREE"),
	MISSLE = pb.enum("PDK_CARD_TYPE", "MISSLE"),
}

cards_util.PDK_CARD_TYPE = PDK_CARD_TYPE

-- 0:黑 1:红 2:梅 3:方

function cards_util.color(card)
	return math.floor(card / 20)
end

function cards_util.value(card)
	return math.floor(card % 20)
end

function cards_util.check(card)
	local color,value = cards_util.color(card),cards_util.value(card)
	return color >= 0 and color <= 5 and value > 0 and value < 16
end

-- 检查牌是否合法
function cards_util.check_cards(cards)
	return table.logic_and(cards,function(c) return cards_util.check(c) end)
end

function cards_util.seek_great_than(kcards,ctype,cvalue,ccount)
	local valuegroup = table.group(kcards,function(_,c) return cards_util.value(c) end)
	local valuecards =  table.map(valuegroup,function(cs,v)  return v,table.values(cs) end)
	local valuecounts = table.map(valuegroup,function(cs,v) return v,table.nums(cs) end)
	local countgroup =  table.group(valuecounts,function(c)  return c end)

	if ctype == PDK_CARD_TYPE.MISSLE then
		return
	end

	if ctype == PDK_CARD_TYPE.SINGLE then
		for i = cvalue + 1,15 do
			if valuecards[i] then return PDK_CARD_TYPE.SINGLE,i end
		end
	end

	if ctype == PDK_CARD_TYPE.DOUBLE then
		for i = cvalue + 1,15 do
			if valuecards[i] and #valuecards[i] >= 2 then  return PDK_CARD_TYPE.DOUBLE,i end
		end
	end

	if ctype == PDK_CARD_TYPE.THREE then
		for i = cvalue + 1,15 do
			if valuecards[i] and #valuecards[i] >= 3 then  return PDK_CARD_TYPE.THREE,i end
		end
	end

	if ctype == PDK_CARD_TYPE.THREE_WITH_ONE then
		for i = cvalue + 1,15 do
			if valuecards[i] and #valuecards[i] >= 3    then return PDK_CARD_TYPE.THREE_WITH_ONE,i end
		end
	end

	if ctype == PDK_CARD_TYPE.THREE_WITH_TWO then
		for i = cvalue + 1,15 do
			if valuecards[i] and #valuecards[i] >= 3  then return PDK_CARD_TYPE.THREE_WITH_TWO,i end
		end
	end

	if ctype == PDK_CARD_TYPE.BOMB then
		for i = cvalue + 1,15 do
			if valuecards[i] and #valuecards[i] == 4  then return  PDK_CARD_TYPE.BOMB,i end
		end
	end

	if ctype == PDK_CARD_TYPE.FOUR_WITH_DOUBLE then
		for i = cvalue + 1,15 do
			if valuecards[i] and #valuecards[i] == 4 and table.sum(valuecards,function(cs,j) return j == i and 0 or #cs end) >= 2  then 
				return PDK_CARD_TYPE.FOUR_WITH_DOUBLE,i 
			end
		end
	end

	if ctype == PDK_CARD_TYPE.FOUR_WITH_THREE then
		for i = cvalue + 1,15 do
			if valuecards[i] and #valuecards[i] == 4  and table.sum(valuecards,function(cs,j) return j == i and 0 or #cs end) >= 3 then 
				return PDK_CARD_TYPE.FOUR_WITH_THREE ,i 
			end
		end
	end

	local function continuity_cards_count(begin,value_count)
		local first_value
		local lian_count = 0
		for i = begin,14 do
			if countgroup[value_count] and countgroup[value_count][i] then
				lian_count = first_value and lian_count + 1 or 1
				first_value = first_value or i
			else
				if first_value then break end
			end
		end

		return lian_count,first_value
	end

	if ctype == PDK_CARD_TYPE.SINGLE_LINE then
		local lian_count,first_value = continuity_cards_count(cvalue + 1,1)
		if lian_count >= ccount then
			return PDK_CARD_TYPE.SINGLE_LINE,first_value
		end
	end

	if ctype == PDK_CARD_TYPE.DOUBLE_LINE then
		local lian_count,first_value = continuity_cards_count(cvalue + 1,2)
		if lian_count >= ccount / 2 then
			return PDK_CARD_TYPE.SINGLE_LINE,first_value
		end
	end

	if ctype == PDK_CARD_TYPE.PLANE then
		local lian_count,first_value = continuity_cards_count(cvalue + 1,3)
		if lian_count >= ccount / 3 then
			return PDK_CARD_TYPE.SINGLE_LINE,first_value
		end
	end

	if ctype == PDK_CARD_TYPE.PLANE_WITH_ONE then
		local lian_count,first_value = continuity_cards_count(cvalue + 1,3)
		if lian_count >= ccount  /  4 then
			return PDK_CARD_TYPE.SINGLE_LINE,first_value
		end
	end

	if ctype == PDK_CARD_TYPE.PLANE_WITH_TWO then
		local lian_count,first_value = continuity_cards_count(cvalue + 1,3)
		if lian_count >= ccount / 5 then
			return PDK_CARD_TYPE.SINGLE_LINE,first_value
		end
	end
end

-- 得到牌类型
function cards_util.get_cards_type(cards)
	local count = #cards
	if count == 1 then
		return PDK_CARD_TYPE.SINGLE, cards_util.value(cards[1]) -- 单牌
	end

	local valuegroup = table.group(cards,function(c) return cards_util.value(c) end)
	local valuecounts = table.map(valuegroup,function(cs,v) return v,table.nums(cs) end)
	local countgroup =  table.group(valuecounts,function(c)  return c end)
	local countvalues = table.map(countgroup,function(cg,c) return c,table.keys(cg) end)
	local countcounts = table.map(countvalues,function(cs,c) return c,table.nums(cs) end)

	if countcounts[4] then
		if (countcounts[1] == 2 or countcounts[2] == 1) and #cards ==  6 then
			return PDK_CARD_TYPE.FOUR_WITH_DOUBLE, countvalues[4][1] -- 四带一
		end

		if (countcounts[3] == 1 or (countcounts[2] == 1 and countcounts[1] == 1) or countcounts[1] == 3) and #cards == 7  then
			return PDK_CARD_TYPE.FOUR_WITH_THREE, countvalues[4][1] -- 四带三
		end

		if not countcounts[1]  and not countcounts[2] and not countcounts[3] then
			return PDK_CARD_TYPE.BOMB,  countvalues[4][1] -- 炸弹
		end

		return nil
	end

	local function max_continuity_cards(begin,value_count)
		local values = {}
		for i = begin,14 do
			if value_count[i] then
				table.insert(values,i)
			elseif #values == 1 then
				values = {}
			end
		end

		return values
	end

	if countcounts[3] then
		if countcounts[3] == 1 then
			if (countcounts[2] == 1 or countcounts[1] == 2) and #cards == 5 then
				return PDK_CARD_TYPE.THREE_WITH_TWO, countvalues[3][1] -- 三带一对
			end

			if countcounts[1] == 1 and #cards == 4  then
				return PDK_CARD_TYPE.THREE_WITH_ONE, countvalues[3][1] -- 三带一
			end

			if not countcounts[1] and not countcounts[2] and #cards == 3 then
				return PDK_CARD_TYPE.THREE, countvalues[3][1] -- 三不带
			end
		end

		if  countcounts[3] > 1 then
			local values = max_continuity_cards(3,countgroup[3])
			log.dump(values)
			if #values < 2 then return end

			if #cards == #values * 3 then
				return PDK_CARD_TYPE.PLANE, values[1] -- 飞机不带牌
			end

			--三带二飞机
			local probobility_3_count = #cards  /  5
			for i = 0,probobility_3_count - 1 do
				if #cards == (#values - i) * 5 then
					return PDK_CARD_TYPE.PLANE_WITH_TWO, values[i + 1]
				end
			end
		end

		return nil
	end


	if countcounts[2] and countcounts[2] > 0 then
		if countcounts[2] == 1 and #cards == 2 then
			return PDK_CARD_TYPE.DOUBLE, countvalues[2][1] -- 对子
		end

		local values = max_continuity_cards(3,countgroup[2])
		if #values >= 3 and #values == countcounts[2]  and #cards == #values * 2 then
			return PDK_CARD_TYPE.DOUBLE_LINE , values[1] -- 连对
		end
	end

	if countcounts[1] and countcounts[1] >= 5 then
		local values = max_continuity_cards(3,countgroup[1])
		if #values >= 5 and #values == countcounts[1] then
			return PDK_CARD_TYPE.SINGLE_LINE , values[1] -- 顺子
		end
	end

	return nil
end

-- 比较牌
function cards_util.compare_cards(l, r)
	if not l  then return r ~= nil  and - 1 or 0 end
	if l and not r then return 1 end

	log.info("cards_util.compare_cards l [%s,%s,%s]", l.type , l.count, l.value)
	log.info("cards_util.compare_cards r [%d,%d,%d]", r.type , r.count, r.value)

	if l.type == PDK_CARD_TYPE.MISSLE then return 1 end
	if r.type == PDK_CARD_TYPE.MISSLE then return -1 end

	if l.type == PDK_CARD_TYPE.BOMB then
		if r.type < PDK_CARD_TYPE.BOMB then return 1 end
		if r.type == PDK_CARD_TYPE.BOMB  and r.value < l.value  then return 1 end
	end

	if r.type == PDK_CARD_TYPE.BOMB then return - 1 end

	if l.type ~= r.type then return end

	if l.type == r.type and l.count == r.count then
		return l.value > r.value and 1 or (l.value < r.value and -1 or 0)
	end

	return
end

return cards_util