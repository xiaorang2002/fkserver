require "functions"
local chronos = require "chronos"
require "random_mt19937"

local table = table

local card_dealer = class("card_dealer")

function card_dealer:ctor(cards)
    self:init(cards)
end

function card_dealer:init(cards)
    self.cards = clone(cards)
    self.remainder_card_count = #self.cards
end

function card_dealer:shuffle()
	math.randomseed(math.floor(chronos.nanotime() * 10000))
	for _ = 1,10 do math.random() end

    local j
    local cards = self.cards
    for i = #cards,2,-1 do
        j = math.random(i - 1)
        cards[j],cards[i] = cards[i],cards[j]
    end

    self.remainder_card_count = #self.cards
end

function card_dealer:deal_one()
    local k = self.remainder_card_count
    local card = self.cards[k]
    self.remainder_card_count = self.remainder_card_count - 1
    return card
end

function card_dealer:deal_one_by_condition(func)
    local k = self.remainder_card_count
    for j = k,1,-1 do
        if func(self.cards[j]) then
            local card = self.cards[j]
            self.cards[j], self.cards[1] = self.cards[1], self.cards[j]
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
		if c and c ~= 0 then table.insert(cards,c)  end
	end
    return cards
end

function card_dealer:deal_cards_by_condition(count,func)
    local cards = {}
    for _ = 1,count do
		local c = self:deal_one_by_condition(func)
		if c and c ~= 0 then table.insert(cards,c) end
	end
    return cards
end

function card_dealer:reserve_cards_count(count)
	self.remainder_card_count = self.remainder_card_count + count
end

function card_dealer:layout_cards(cards,begin)
    begin = begin or 1
    local size = #self.cards
    local cardindex = table.map(self.cards,function(c,i) return c,i end)
    for i,c in pairs(cards) do
        local j = cardindex[c]
        assert(j,"layout_cards invalid card:"..tostring(c))
        local k = size - (begin + i - 1) + 1
        local ck = self.cards[k]
        cardindex[c],cardindex[ck] = cardindex[ck],cardindex[c]
        self.cards[j],self.cards[k] = self.cards[k],self.cards[j]
    end
end

function card_dealer:left_cards()
    return table.slice(self.cards,1,self.remainder_card_count)
end

return card_dealer