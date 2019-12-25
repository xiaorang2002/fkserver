require "functions"

local card_dealer = class("card_dealer")

function card_dealer:ctor(include_joker,begin_num,end_num)
    self:init(include_joker,begin_num,end_num)
end

function card_dealer:init(include_joker,begin_num,end_num)
    math.randomseed(os.time())
	for _ = 1,10 do math.random() end

    self.cards = {}
    for i = 0,3 do
        for j = begin_num,end_num do table.push_back(self.cards,i * 15 + j) end
    end

	if include_joker then
		table.push_back(61)
		table.push_back(62)
	end

    self.remainder_card_count = #self.cards
end

function card_dealer:shuffle()
	math.randomseed(os.time())
	for _ = 1,10 do math.random() end

    for i = #self.cards,1,-1 do
        local j = math.random(i)
        if i ~= j then self.cards[j],self.cards[i] = self.cards[i],self.cards[j] end
    end

    self.remainder_card_count = #self.cards
end

function card_dealer:deal_one()
	local k = self.remainder_card_count
    local j = math.random(k)
    local card = self.cards[j]
    if j ~= k then self.cards[j], self.cards[k] = self.cards[k], self.cards[j] end
    self.remainder_card_count = self.remainder_card_count - 1
    return card
end

function card_dealer:deal_one_by_condition(func)
    local k = self.remainder_card_count
    for j = 1,k do
        if func(self.cards[j]) then
            local card = self.cards[j]
            if j ~= k then self.cards[j], self.cards[k] = self.cards[k], self.cards[j] end
            self.remainder_card_count = self.remainder_card_count - 1
            return card
        end
    end

    return 0
end

function card_dealer:deal_cards(count)
    local cards = {}
    for _ = 1,count do
		local c = self:deal_one()
		if c ~= 0 then table.push_back(cards,c)  end
	end
    return cards
end

function card_dealer:deal_cards_by_condition(count,func)
    local cards = {}
    for _ = 1,count do
		local c = self:deal_one_by_condition(func)
		if c ~= 0 then table.push_back(cards,c) end
	end
    return cards
end

function card_dealer:reserve_cards_count(count)
	self.remainder_card_count = self.remainder_card_count + count
end

return card_dealer