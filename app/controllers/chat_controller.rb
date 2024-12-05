class ChatController < ApplicationController
  def index
    # This will render app/views/chat/index.html.erb
  end

  def chat
    question = params[:question]
    response = fetch_response(question)
    render json: { text: response_to_html(response), markdown: true }
  rescue StandardError => e
    render json: { error: "Error: #{e.message}" }, status: :internal_server_error
  end

  private

  def ai_conversation(message)
    ai = Langchain::LLM::GoogleGemini.new(api_key: ENV['API_KEY'])
    ai.chat(messages: [{role: "user", parts: [{text: message}]}])
  end

  def fetch_response(question)
    ai_conversation(question).chat_completion
  end

  def response_to_html(response)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, fenced_code_blocks: true)
    markdown.render(response)
  end
end