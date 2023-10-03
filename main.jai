#import "Basic";

#load "./jsqlite3.jai";

main :: () {
    db: *sqlite3;
    res := sqlite3_open(":memory:", *db);

    print("Connection to databese: %\n", res);
    print("Sqlite3 version: %\n", sqlite3_libversion());

    // err_msg: [256]u8;
    err_msg: string = "                                                                          .";

    script := "create tooble if not exists User (name text primary key, password text not null);";

    rc := sqlite3_exec(db, script.data, xx 0, xx 0, *err_msg.data);

    print("rc is: %\n", rc);
    print("Error message: %\n", err_msg.data);

    sqlite3_close(db);
}