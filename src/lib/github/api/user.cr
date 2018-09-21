module GitHub::API
  struct User
    JSON.mapping(
      login: String,
      id: Int32,
      avatar_url: String | Nil,
      type: String,
      site_admin: Bool,
      name: String | Nil,
      company: String | Nil,
      blog: String,
      location: String | Nil,
      hireable: Bool | Nil,
      bio: String | Nil,
      followers: Int32,
      created_at: Time,
    )
  end
end
