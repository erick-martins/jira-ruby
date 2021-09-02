module JIRA
  module Resource
    class VersionFactory < JIRA::BaseFactory # :nodoc:
    end

    class Version < JIRA::Base
      def self.all(client, options)
        path = path_base(client, options)

        response = client.get(path)
        json = parse_json(response.body)
        results = json['values']

        until json['isLast']
          params = { 'startAt' => (json['startAt'] + json['maxResults']).to_s }
          response = client.get(url_with_query_params(path, params))
          json = parse_json(response.body)
          results += json['values']
        end

        results.map do |version|
          client.Version.build(version)
        end
      end


      def self.find(client, options)
        path = path_base(client, options)
        query_params = {
          "query" => options[:query],
          "status" => options[:status],
          "orderBy" => options[:orderBy]
        }
        .compact


        response = client.get(url_with_query_params(path, query_params))
        json = parse_json(response.body)
        results = json['values']

        until json['isLast']
          params = { 'startAt' => (json['startAt'] + json['maxResults']).to_s }
          response = client.get(url_with_query_params(path, params))
          json = parse_json(response.body)
          results += json['values']
        end

        results.map do |version|
          client.Version.build(version)
        end
      end

      private

      def self.path_base(client, options)
        project_id_or_key = options[:project_id_or_key]

        client.options[:rest_base_path] + "/project/#{project_id_or_key}/version"
      end

      def path_base(client, options)
        self.class.path_base(client, options)
      end
    end
  end
end
