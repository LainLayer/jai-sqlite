#run build();

build :: () {
    set_build_options_dc(.{do_output=false});

    options := get_build_options();

    if !file_exists("jsqlite3.a") {
        success := build_cpp_static_lib("jsqlite3", "sqlite/bld/sqlite3.c", debug=true);

        if !success {
            print("Failed to build sqlite\n");
            compiler_set_workspace_status(.FAILED);
            return;
        }
    }

    if !file_exists("jsqlite3.jai") {
        if !generate_bindings() {
            print("Failed to generate bindings for sqlite\n");
            compiler_set_workspace_status(.FAILED);
            return;
        }
    }

    w := compiler_create_workspace("Main program");

    options.output_type     = .EXECUTABLE;
    options.output_executable_name = "piss";
    set_build_options(options, w);

    compiler_begin_intercept(w);
    add_build_file("main.jai", w);

    while true {
        message := compiler_wait_for_message();
        if message.kind == {
          case .TYPECHECKED;
            do_error_checking(null, message);

          case .COMPLETE;
            break;
        }
    }

    compiler_end_intercept(w);

}

generate_bindings :: () -> bool {
    output_filename := "jsqlite3.jai";
    opts: Generate_Bindings_Options;

    {
        using opts;
        // array_add(*libpaths,     "sqlite/bld/");
        array_add(*libnames,     "jsqlite3");
        array_add(*source_files, "sqlite/bld/sqlite3.h");
        // array_add(*source_files, "sqlite/bld/sqlite3.c");
    }
    return generate_bindings(opts, output_filename);
}



#scope_file

#import "Basic";
#import "Compiler";
#import "BuildCpp";
#import "Check";
#import "Bindings_Generator";
#import "File";
#import "File_Utilities";