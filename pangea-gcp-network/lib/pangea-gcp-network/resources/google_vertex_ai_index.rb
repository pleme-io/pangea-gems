def google_vertex_ai_index(name:, display_name:, description:, region:, labels:, metadata:, index_update_method:)
  resource :google_vertex_ai_index, name do
    display_name display_name
    description  description
    region       region
    labels(labels)
    metadata(metadata)
    index_update_method index_update_method
  end
  { id: "${google_vertex_ai_index.#{name}.id}" }
end