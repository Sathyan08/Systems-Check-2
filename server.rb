require 'sinatra'

require 'sinatra/reloader'

require 'csv'


def pull_game_data(filename)

  game_data = []

  CSV.foreach(filename, headers:true) do |row|
    game_data<< row
  end

  game_data
end

def extract_team_names(game_data)

  team_names = []

  game_data.each do |game|
    team_names << game["home_team"]
    team_names << game["away_team"]
  end

  team_names.uniq
end



def pull_team_data(filename,team_name)

  team_data = []

  CSV.foreach(filename, {headers:true, header_converters: symbol, converters:all}) do |row|
    if row["home_team"] == team_name || row["away_team"] == team_name
      team_data<< row
    end
  end

  team_data
end

def create_leader_board

  leaderboard = []  ### this will be an array of hashes

  team_names.each do |team_name|
    wins[team_name] = 0
    loses[team_name] = 0
  end

  game_data.each do |game|
    if game["home_score"] > game["away_score"]
      wins["home_team"] += 1
      loses["away_team"] += 1
    else
      wins["away_team"] += 1
      loses["home_team"] += 1
    end

    wins.sort_by! {|team_name, wins| wins}
    wins.reverse!

    # loses.sort_by! {|team_name, loses| loses}

  wins.each do |team_name, win_number|
    team_hash[:team_name] = team_name
    team_hash[:wins] = win_number
  end



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

  erb :leaderboard
end

get '/team/:team' do
  @team = params[:team]
  @team_data = pull_team_data("game_data.csv", @team)

  erb :team
end

