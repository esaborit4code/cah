class GamesController < ApplicationController
  helper_method :current_player, :current_question, :previous_questions, :missing_answers,
                :current_player_unused_answers, :in_players
  after_action :broadcast_action, only: %i(clear enter_player drop_player leave_answer choose_winner_answer)

  def clear
    clear_game
    redirect_to action: :new_player
  end

  def new_player
    redirect_to action: :show if current_player.present?
  end

  def enter_player
    @current_player = Player.find_or_create_by(player_params)
    cookies[:player_id] = current_player.id
    current_player.in!
    draw_answers

    current_player.tzar! if Player.human.count == 1
    start_round if Player.human.count == 2

    redirect_to action: :show
  end

  def drop_player
    current_player.answers.unused.update_all(player_id: nil)
    current_player.player!
    current_player.out!
    @current_player = nil
    cookies[:player_id] = nil

    if Player.human.in.none?
      clear_game
    else
      Player.human.in.first.tzar!
    end

    redirect_to action: :new_player
  end

  def show
    return redirect_to action: :new_player if current_player.blank?
    render 'empty' if Player.human.in.count < 2
  end

  def leave_answer
    answer = Answer.find(params.require(:answer)[:id])
    current_question.answers << answer
    draw_answers
    leave_random_answers if current_question.answers.count == Player.player.count

    redirect_to action: :show
  end

  def choose_winner_answer
    answer = Answer.find(params.require(:answer)[:id])
    answer.update(winner: true)

    unless answer.player.random?
      current_player.player!
      answer.player.tzar!
    end

    start_round

    redirect_to action: :show
  end

  protected

  def start_round
    round_in_progress = current_question.present? && current_question.answers.none?(&:winner?)
    return if round_in_progress
    draw_question
  end

  def draw_question
    previous_round = @current_question.try(:round) || 0
    @current_question = Question.where(round: nil, gaps: 1).all.sample
    @current_question.update(round: previous_round + 1)
  end

  def leave_random_answers
    Player.random.each do |player|
      answer = Answer.where(player_id: nil).all.sample
      answer.update(player: player, question: current_question)
    end
  end

  def draw_answers
    answers_to_draw = 7 - current_player.answers.unused.count
    current_player.answers += Answer.where(player: nil).all.sample(answers_to_draw)
    current_player.save
  end

  def player_params
    params.require(:player).permit(:name)
  end

  def current_player
    @current_player ||= Player.find_by(id: cookies[:player_id])
  end

  def current_question
    @current_question ||= Question.where.not(round: nil).order(:round).last
  end

  def previous_questions
    Question.where.not(id: current_question.id, round: nil).order(round: :desc)
  end

  def missing_answers
    Player.in.where.not(role: :tzar).count - current_question.answers.count
  end

  def current_player_unused_answers
    current_player.answers.unused.order(:updated_at)
  end

  def broadcast_action
    ActionCable.server.broadcast('game', nil)
  end

  def in_players
    Player.in
  end

  def clear_game
    Answer.update_all(player_id: nil, question_id: nil)
    Question.update_all(round: nil)
    Player.human.destroy_all
  end
end
