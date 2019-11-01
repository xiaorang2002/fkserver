
scene = {

[1] = { id = 1,time=600, map="Map_0.jpg", bmg="bgm1.mp3", next=2,
	troop_set = {{ begin_time=300, end_time=360, id=4, }},
	distrub_fish = {
        {time=45, count = {min=3, max = 6},  type_list={200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219}, weight_list={100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
	    {time=22, count = {min=5, max = 8}, type_list={2,3,4,5}, weight_list={100,100,100,100}, refersh_type=2, offest = {x=50, y = 50}, offest_time=0.5},
	    {time=18, count = {min=8, max = 15}, type_list={1,2,3}, weight_list={100,100,100}, refersh_type=1, offest = {x=50, y = 50}, offest_time=1},
	    {time=3, count = {min=1, max = 3}, type_list={1,2,3,4,5,6,7,8,9}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
	    {time=8, count = {min=2, max = 4}, type_list={10,11,12,13,14,15}, weight_list={100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
	    {time=10, count = {min=1, max = 3}, type_list={16,17,18,19,20,21,22,23,24}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
	    {time=13, count = {min=1, max = 3}, type_list={16,17,18,19,20,21,22,23,24}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
	    {time=40, count = {min=1, max = 1}, type_list={25,29}, weight_list={100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
	    {time=100, count = {min=1, max = 1}, type_list={500}, weight_list={100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
	    {time=35, count = {min=1, max = 1}, type_list={701,702,703,704,705,801,802,803}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
	    {time=30, count = {min=1, max = 1},  type_list={601,602,603,604,605,606,607,608,609,610}, weight_list={100,100,100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
	    {time=36, count = {min=1, max = 1}, type_list={300,301}, weight_list={100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
    },
},

[2] = { id = 2,time=600, map="Map_1.jpg", bmg="bgm2.mp3", next=3,
	troop_set = {{ begin_time=300, end_time=360, id=5, }},
	distrub_fish = {
		{time=45, count = {min=3, max = 6},  type_list={200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219}, weight_list={100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=22, count = {min=5, max = 8}, type_list={2,3,4,5}, weight_list={100,100,100,100}, refersh_type=2, offest = {x=50, y = 50}, offest_time=0.5},
		{time=18, count = {min=8, max = 15}, type_list={1,2,3}, weight_list={100,100,100}, refersh_type=1, offest = {x=50, y = 50}, offest_time=1},
		{time=3, count = {min=1, max = 3}, type_list={1,2,3,4,5,6,7,8,9}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=8, count = {min=2, max = 4}, type_list={10,11,12,13,14,15}, weight_list={100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=10, count = {min=1, max = 3}, type_list={16,17,18,19,20,21,22,23,24}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=13, count = {min=1, max = 3}, type_list={16,17,18,19,20,21,22,23,24}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=40, count = {min=1, max = 1}, type_list={25,29}, weight_list={100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=100, count = {min=1, max = 1}, type_list={500}, weight_list={100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=35, count = {min=1, max = 1}, type_list={701,702,703,704,705,801,802,803}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=30, count = {min=1, max = 1},  type_list={601,602,603,604,605,606,607,608,609,610}, weight_list={100,100,100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=36, count = {min=1, max = 1}, type_list={300,301}, weight_list={100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2}
	},
},

[3] = { id = 3,time=600, map="Map_2.jpg", bmg="bgm3.mp3", next=4,
	troop_set = {{ begin_time=300, end_time=360, id=6, }},
	distrub_fish = {
		{time=45, count = {min=3, max = 6},  type_list={200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219}, weight_list={100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=22, count = {min=5, max = 8}, type_list={2,3,4,5}, weight_list={100,100,100,100}, refersh_type=2, offest = {x=50, y = 50}, offest_time=0.5},
		{time=18, count = {min=8, max = 15}, type_list={1,2,3}, weight_list={100,100,100}, refersh_type=1, offest = {x=50, y = 50}, offest_time=1},
		{time=3, count = {min=1, max = 3}, type_list={1,2,3,4,5,6,7,8,9}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=8, count = {min=2, max = 4}, type_list={10,11,12,13,14,15}, weight_list={100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=10, count = {min=1, max = 3}, type_list={16,17,18,19,20,21,22,23,24}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=13, count = {min=1, max = 3}, type_list={16,17,18,19,20,21,22,23,24}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=40, count = {min=1, max = 1}, type_list={25,29}, weight_list={100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=100, count = {min=1, max = 1}, type_list={500}, weight_list={100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=35, count = {min=1, max = 1}, type_list={701,702,703,704,705,801,802,803}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=30, count = {min=1, max = 1},  type_list={601,602,603,604,605,606,607,608,609,610}, weight_list={100,100,100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=36, count = {min=1, max = 1}, type_list={300,301}, weight_list={100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2}
	},
},

[4] = { id = 4,time=600, map="Map_1.jpg", bmg="bgm2.mp3", next=5,
	troop_set = {{ begin_time=300, end_time=360, id=7, }},
	distrub_fish = {
		{time=45, count = {min=3, max = 6},  type_list={200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219}, weight_list={100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=22, count = {min=5, max = 8}, type_list={2,3,4,5}, weight_list={100,100,100,100}, refersh_type=2, offest = {x=50, y = 50}, offest_time=0.5},
		{time=18, count = {min=8, max = 15}, type_list={1,2,3}, weight_list={100,100,100}, refersh_type=1, offest = {x=50, y = 50}, offest_time=1},
		{time=3, count = {min=1, max = 3}, type_list={1,2,3,4,5,6,7,8,9}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=8, count = {min=2, max = 4}, type_list={10,11,12,13,14,15}, weight_list={100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=10, count = {min=1, max = 3}, type_list={16,17,18,19,20,21,22,23,24}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=13, count = {min=1, max = 3}, type_list={16,17,18,19,20,21,22,23,24}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=40, count = {min=1, max = 1}, type_list={25,29}, weight_list={100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=100, count = {min=1, max = 1}, type_list={500}, weight_list={100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=35, count = {min=1, max = 1}, type_list={701,702,703,704,705,801,802,803}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=30, count = {min=1, max = 1},  type_list={601,602,603,604,605,606,607,608,609,610}, weight_list={100,100,100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=36, count = {min=1, max = 1}, type_list={300,301}, weight_list={100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2}
	},
},

[5] = { id = 5,time=600, map="Map_3.jpg", bmg="bgm4.mp3", next=1,
	troop_set = {{ begin_time=300, end_time=360, id=8, }},
	distrub_fish = {
		{time=45, count = {min=3, max = 6},  type_list={200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219}, weight_list={100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=22, count = {min=5, max = 8}, type_list={2,3,4,5}, weight_list={100,100,100,100}, refersh_type=2, offest = {x=50, y = 50}, offest_time=0.5},
		{time=18, count = {min=8, max = 15}, type_list={1,2,3}, weight_list={100,100,100}, refersh_type=1, offest = {x=50, y = 50}, offest_time=1},
		{time=3, count = {min=1, max = 3}, type_list={1,2,3,4,5,6,7,8,9}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=8, count = {min=2, max = 4}, type_list={10,11,12,13,14,15}, weight_list={100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=10, count = {min=1, max = 3}, type_list={16,17,18,19,20,21,22,23,24}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=13, count = {min=1, max = 3}, type_list={16,17,18,19,20,21,22,23,24}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=40, count = {min=1, max = 1}, type_list={25,29}, weight_list={100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=100, count = {min=1, max = 1}, type_list={500}, weight_list={100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=35, count = {min=1, max = 1}, type_list={701,702,703,704,705,801,802,803}, weight_list={100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=30, count = {min=1, max = 1},  type_list={601,602,603,604,605,606,607,608,609,610}, weight_list={100,100,100,100,100,100,100,100,100,100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2},
		{time=36, count = {min=1, max = 1}, type_list={300,301}, weight_list={100,100}, refersh_type=0, offest = {x=50, y = 50}, offest_time=2}
	},
},
}