require 'sinatra'

require 'sinatra/reloader'

require 'csv'


def pull_game_data(filename)

  game_data = []

  CSV.foreach(filename, {headers:true, :header_converters => :symbol, :converters => :all}) do |row|
    game_data<< row
  end

  game_data
end

def extract_team_names(game_data)

  team_names = []

  game_data.each do |game|
    team_names << game[:home_team]
    team_names << game[:away_team]
  end

  team_names.uniq
end



def pull_team_data(filename,team_name)

  team_data = []

  CSV.foreach(filename, {headers:true, header_converters: :symbol, converters: :all}.merge) do |row|
    if row[:home_team] == team_name || row[:away_team] == team_name
      team_data<< row
    end
  end

  team_data
end

def create_leader_board(game_data,team_names)

  leaderboard = []  ### this will be an array of hashes in the end


      ##### 1. Tabulate each team's wins and losses.#####
  wins = {}
  loses = {}

  team_names.each do |team_name|
    wins[team_name] = 0
    loses[team_name] = 0
  end

  game_data.each do |game|


    if game[:home_score] > game[:away_score]
      wins[game[:home_team]] += 1
      loses[game[:away_team]] += 1
    else
      wins[game[:away_team]] += 1
      loses[game[:home_team]] += 1
    end
  end
    wins_sorted = wins.sort_by {|team_name, wins| wins}
    wins_sorted.reverse!

    ###### 2. Create the basis for the leaderboard by taking the wins hash as the basis.
    ######    The wins hash is sorted properly with highest wins appearing first, so
    ######    the leaderboard will also be sorted by wins.

  wins_sorted.each do |team_name, wins_number|
    leaderboard_position = {}
    leaderboard_position[:name] = team_name
    leaderboard_position[:wins] = wins_number
    leaderboard_position[:loses] = loses[team_name]
    leaderboard << leaderboard_position
  end

    ###### 3. The next step is to reorder teh leaderboard by loses.
    ######    For teams with the same number of wins, teams with more
    ######    loses will be ranked lower than teams with fewer loses.


  leaderboard_copy = leaderboard  ###create a copy to account for destructive selection
                                  ###when pushing values into a final data set

  wins_groups = []

  leaderboard_copy.each do |copy_position|  #### identifies all possible values for wins
    wins_group = []                         #### then creates a subgroup for each value
    wins_group << copy_position[:wins]
    wins_groups << wins_group
  end

  wins_groups.uniq!

  wins_groups.each do |wins_group|          ###### matches each team with its win subgroup
    leaderboard.each do |leaderboard_position|
      if leaderboard_position[:wins] == wins_group[0]
        wins_group << leaderboard_position
      end
    end
  end

final_leaderboard = []

  wins_groups.each do |wins_group|          #### sorts each win subgroup by loses
    wins_group.shift                #### gets rid of the original wins number that is no longer needed
    wins_group.sort_by! {|leaderboard_position| leaderboard_position[:loses]}
    until wins_group.length == 0
      final_leaderboard << wins_group.shift
    end
  end

final_leaderboard

end


##############################
##############################
##############################

get '/' do
  @game_data = pull_game_data("game_data.csv")

  @team_names = extract_team_names(@game_data)

  erb :index
end

get '/leaderboard' do
  @game_data = pull_game_data("game_data.csv")
  @team_names = extract_team_names(@game_data)
  @leaderboard = create_leader_board(@game_data,@team_names)

  erb :leaderboard
end

get '/team/:team' do
  @team = params[:team]
  @game_data = pull_game_data("game_data.csv")
  @team_names = extract_team_names(@game_data)
  @leaderboard = create_leader_board(@game_data,@team_names)

  # @team_data = pull_team_data("game_data.csv", @team)

  erb :team
end

