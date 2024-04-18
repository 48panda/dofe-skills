require 'json'

def wait_for_user_input(player)
    print "#{player.name}, press enter to roll."
    gets.chomp
end

def get_dice_roll
    (rand * 6).floor + 1
    # 3 # To test tie breaks
end

def get_dice_roll_tie
    (rand * 6).floor + 1
    # (rand * 2).floor + 1 # To test tie breaks
end

def roll_two_dice(player)
    wait_for_user_input(player)
    num1 = get_dice_roll
    num2 = get_dice_roll
    puts "#{player.name} rolled a #{num1} and a #{num2}."
    total = num1 + num2
    doubles = num1 == num2
    return total, doubles
end

def add_other_points(roll, player)
    message = "The dice sum to #{roll}, so #{roll} points are given.\n"
    player.score += roll
    if roll % 2 == 0 then
       message += "As #{roll} is even, 10 additional points have been given\n" 
       player.score += 10
    else
        message += "As #{roll} is odd, 5 points have been removed.\n"
        player.score -= 5
    end
    # This is the only place a score could be negative, so check for it here.
    if player.score < 0 then
        player.score = 0 # The total will be 0.
        message += "To avoid a negative score, the #{player.name}'s total score has been set to zero.\n"
    end
    print message
end

def doubles_bonus(player)
    puts "As #{player.name} rolled doubles, they get to roll another dice!"
    wait_for_user_input(player)
    bonus_roll = get_dice_roll
    puts "#{player.name} rolled #{bonus_roll}. #{bonus_roll} points have been added."
    player.score += bonus_roll
end

class Player
    attr_reader :name
    attr_accessor :score
    @@total_turns_remaining = 10
    def initialize(name)
        @name = name
        @score = 0
    end

    def do_turn
        roll, doubles = roll_two_dice(self)
        add_other_points(roll, self)
        if doubles then
            doubles_bonus(self)
        end
        puts "#{@name}'s new score is #{@score}"
        @@total_turns_remaining -= 1
    end

    def continue?
        @@total_turns_remaining > 0
    end
end

def tiebreak(p1, p2)
    puts "Everyone has the same points! A tiebreak is needed!"
    wait_for_user_input(p1)
    d1 = get_dice_roll_tie
    puts "#{p1.name} rolled a #{d1}.\n\n"
    wait_for_user_input(p2)
    d2 = get_dice_roll_tie
    puts "#{p2.name} rolled a #{d2}.\n\n"
    if d1 > d2 then
        return 1
    elsif d1 < d2 then
        return 2
    else
        return tiebreak(p1, p2)
    end
end

def update_leaderboard(player)
    rfile = File.new("leaderboard.json", "r")
    json = JSON.parse rfile.read
    rfile.close
    json.append({"name"=> player.name, "score"=> player.score})
    json = json.sort_by do |hash|
        hash["score"]
    end.reverse
    while json.length > 5
        json.pop
    end
    wfile = File.new("leaderboard.json", "w")
    wfile.write json.to_json
    wfile.close
end

def print_leaderboard
    rfile = File.new("leaderboard.json", "r")
    json = JSON.parse rfile.read
    rfile.close
    json = json.sort_by do |hash|
        hash["score"]
    end
    json.each do |hash|
        puts "#{hash["name"]} scored #{hash["score"]}"
    end
end

print "What is Player 1's name? "
current_player = Player.new(gets.chomp)
print "What is Player 2's name? "
other_player = Player.new(gets.chomp)


while current_player.continue?
    current_player.do_turn
    puts
    current_player, other_player = other_player, current_player
end
if current_player.score > other_player.score then
    winner = 1
elsif current_player.score < other_player.score then
    winner = 2
else
    winner = tiebreak(current_player, other_player)
end

if winner == 2 then
    winner, loser = other_player, current_player
else
    winner, loser = current_player, other_player
end

puts "#{winner.name} wins with #{winner.score} points!"
puts "#{loser.name} lost with #{loser.score} points."

puts
puts

update_leaderboard(winner)
print_leaderboard()
