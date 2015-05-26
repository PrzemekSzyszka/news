require_relative '../base'

module API
  class Stories < Base
    namespace '/v2' do
      get '/stories' do
        popular_stories = Story.popular
        last_modified(popular_stories.first.board.updated_at)
        respond_with popular_stories
      end

      get '/recent&?:per_page?&?:pagee?' do
        page      = request.params.fetch('page', 1).to_i
        per_page  = request.params.fetch('per_page', 10).to_i
        elements = Story.recent.page(page).per(per_page)
        set_link_header(elements, per_page)

        respond_with elements
      end

      get '/stories/:id' do |id|
        respond_with Story.find(id)
      end

      get '/stories/:id/url' do |id|
        redirect Story.find(id).url, 302
      end

      post '/stories' do
        user = authenticate!
        board = Board.first
        board = Board.create!(name: 'example') if board.nil?
        story = Story.create!(title: @data['title'], url: @data['url'], user_id: user.id, board: board)

        status 201
        headers['Location'] = '/v2/stories'
        respond_with(id: story.id, score: story.score)
      end

      put '/stories/:id' do |id|
        user = authenticate!

        if story = user.stories.find_by(id: id)
          story.update(@data)

          status 204
          headers['Location'] = '/v2/stories'
          respond_with(id: story.id, score: story.score)
        else
          raise AuthorizationError
        end
      end

      patch '/stories/:id/vote' do
        user = authenticate!
        vote = Vote.find_or_create_by(user_id: user.id, story_id: params['id'])
        vote.value = @data['delta']
        vote.save

        status 204
      end

      delete '/stories/:id/vote' do |id|
        user = authenticate!
        vote = Vote.find_by(user_id: user.id, story_id: id)
        Vote.delete(vote) if vote

        status 204
      end

      delete '/stories/:id' do |id|
        user = authenticate!
        Story.destroy(id) if user.stories.find(id)
        status 204
      end

      private

      def set_link_header(elements, per_page)
        next_page = elements.next_page
        last_page = elements.total_pages
        prev_page = elements.prev_page

        response['Link'] = "<#{url_for request.path_info, :full}&per_page=#{per_page}&page=#{next_page}>; rel='next'" unless next_page.nil?
        append_last_page_link(last_page, next_page, per_page)
        append_prev_page_link(prev_page, per_page)
        append_first_page_link(prev_page, per_page)
      end

      def append_last_page_link(last_page, next_page, per_page)
        if last_page.present? && next_page.present? && last_page > next_page  && response['Link'].present?
          response['Link'] = "#{response['Link']}, <#{url_for request.path_info, :full}&per_page=#{per_page}&page=#{last_page}>; rel='last'"
        elsif last_page.present? && next_page.present? && last_page > next_page
          response['Link'] = "<#{url_for request.path_info, :full}&per_page=#{per_page}&page=#{last_page}>; rel='last'"
        end
      end

      def append_prev_page_link(prev_page, per_page)
        if prev_page.present? && response['Link'].present?
          response['Link'] = "#{response['Link']}, <#{url_for request.path_info, :full}&per_page=#{per_page}&page=#{prev_page}>; rel='prev'"
        elsif prev_page.present?
          response['Link'] = "<#{url_for request.path_info, :full}&per_page=#{per_page}&page=#{prev_page}>; rel='prev'"
        end
      end

      def append_first_page_link(prev_page, per_page)
        if prev_page.present? && 1 < prev_page  && response['Link'].present?
          response['Link'] = "#{response['Link']}, <#{url_for request.path_info, :full}&per_page=#{per_page}&page=1>; rel='first'"
        elsif prev_page.present? && 1 < prev_page
          response['Link'] = "<#{url_for request.path_info, :full}&per_page=#{per_page}&page=1>; rel='first'"
        end
      end
    end
  end
end
