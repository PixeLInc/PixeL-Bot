require "big"
require "pg"

module SGM::Web
  class DB
    module Query
      CreateUser = <<-SQL
        INSERT INTO users (discord_id, access_token, verification_code) VALUES($1, $2, $3) ON CONFLICT DO NOTHING;
        SQL

      UpdateUser = <<-SQL
        UPDATE users SET
          mcuser = $1,
          verification_code = null
        WHERE
          discord_id = $2;
        SQL

      UpdateUserByCode = <<-SQL
        UPDATE users SET
          mcuser = $1,
          verification_code = null
        WHERE
          verification_code = $2;
        SQL

      GetUserByID = <<-SQL
        SELECT
          discord_id,
          access_token,
          mcuser,
          verification_code
        FROM
          users
        WHERE
          discord_id = $1;
        SQL

      GetUserByName = <<-SQL
        SELECT
          id,
          discord_id,
          access_token,
          mcuser,
          verification_code
        FROM
          users
        WHERE
          mcuser = $1;
        SQL

      GetUserByCode = <<-SQL
        SELECT
          id,
          discord_id,
          access_token,
          mcuser,
          verification_code
        FROM
          users
        WHERE
          verification_code = $1;
        SQL

      DeleteUserByID = <<-SQL
        DELETE FROM
          users
        WHERE
          discord_id = $1;
        SQL

      DeleteUserByName = <<-SQL
        DELETE FROM
          users
        WHERE
          discord_id = $1;
        SQL

      CheckUserExist = <<-SQL
        SELECT
          mcuser
        FROM
          users
        WHERE
          discord_id = $1
        LIMIT
          1;
      SQL
    end

    struct User
      ::DB.mapping(
        id: Int32,
        discord_id: PG::Numeric,
        access_token: String,
        mcuser: String?,
        verification_code: String?
      )
    end

    getter db : ::DB::Database

    def initialize(url : String)
      @db = ::DB.open(url)
    end

    delegate close, to: @db

    def get_mc(discord_id : UInt64)
      begin
        db.query_one(Query::CheckUserExist, discord_id, as: {String})
      rescue ex
        ""
      end
    end

    def create_user(discord_id : UInt64, access_token : String, verification_code : String)
      db.exec(Query::CreateUser, discord_id, access_token, verification_code)
    end

    def update_user(discord_id : UInt64, mcuser : String)
      db.exec(Query::UpdateUser, mcuser, discord_id)
    end

    def update_user(code : String, mcuser : String)
      db.exec(Query::UpdateUserByCode, mcuser, code)
    end

    def get_user(discord_id : UInt64)
      rs = db.query(Query::GetUserByID, discord_id)
      User.from_rs(rs)
    end

    def get_user(mcuser : String)
      rs = db.query(Query::GetUserByName, mcuser)
      User.from_rs(rs)
    end

    def delete_customer(discord_id : UIn64)
      db.exec(Query::DeleteUserByID, discord_id)
    end

    def delete_customer(mcuser : String)
      db.exec(Query::DeleteUserByName, mcuser)
    end
  end
end
