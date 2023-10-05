#import "Basic";

#load "./jsqlite3.jai";

#add_context db:  *sqlite3;
#add_context err: *u8;

User :: struct {
    name, password: string;
}

main :: () {
    using context;

    res := sqlite3_open(":memory:", *db);

    print("Connection to databese: %\n", res);
    print("Sqlite3 version: %\n", to_string(sqlite3_libversion()));


    script := #string END
        create table if not exists User (
            name text primary key,
            password text not null
        );

        insert into User (name, password) values
            ("Bob",   "password1"),
            ("Billy", "password2"),
            ("Steve", "password3"),
            ("Fred",  "password5");
    END

    if sqlite3_exec(db, script.data, xx 0, xx 0, *err) != 0 {
        print("Error message: %\n", to_string(err));
        sqlite3_free(err);
    }

    users := get_users();

    for users
        print("user - name: %, password: %\n", it.name, it.password);

    print("Total temporary memory allocaed: % bytes.\n",
        temporary_storage.total_bytes_occupied);

    reset_temporary_storage();

    sqlite3_close(db);
}

to_string_copy :: (s: *u8) -> string {
    /*
        Sqlite3 will free strings it provides.
        To preserve the data, it gets copied into the string,
        as opposed to to_string() which keeps the original pointer.
    */
    if !s return "";

    result: string;
    result.count = c_style_strlen(s);
    result.data  = alloc(result.count, temp);
    memcpy(result.data, s, result.count);
    return result;
}

get_users :: () -> [..] User {
    using context;
    stmt: *sqlite3_stmt;

    sqlite3_prepare_v2(db, "select * from User;", -1, *stmt, xx 0);

    users: [..] User;
    users.allocator = temp;

    while sqlite3_step(stmt) == SQLITE_ROW {
        array_add(*users, User.{
            to_string_copy(cast(*u8) sqlite3_column_text(stmt, 0)),
            to_string_copy(cast(*u8) sqlite3_column_text(stmt, 1))
        });
    }

    sqlite3_finalize(stmt);

    return users;
}