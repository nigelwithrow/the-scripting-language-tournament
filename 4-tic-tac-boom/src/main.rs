fn win(board: &[char; 9]) -> char {
    macro_rules! check {
        ($a:expr, $b:expr, $c:expr) => {
            let (a, b, c): (char, char, char) = (board[$a], board[$b], board[$c]);
            let (a, b, c) = (
                a.to_ascii_lowercase(),
                b.to_ascii_lowercase(),
                c.to_ascii_lowercase(),
            );
            if b == a && c == a {
                return a;
            }
        };
    }

    // Rows
    for row in 0..3 {
        check!(row * 3, row * 3 + 1, row * 3 + 2);
    }
    // Cols
    for col in 0..3 {
        check!(col, col + 3, col + 6);
    }
    // Diagonals
    check!(0, 4, 8);
    check!(2, 4, 6);
    ' '
}

fn print_board(board: &[char; 9]) {
    println!("");
    println!("{}|{}|{}", board[0], board[1], board[2]);
    println!("-----");
    println!("{}|{}|{}", board[3], board[4], board[5]);
    println!("-----");
    println!("{}|{}|{}", board[6], board[7], board[8]);
}

fn human(_: &[char; 9]) -> usize {
    print!("Your move (0-8): ");
    let mut input = String::new();
    std::io::stdin().read_line(&mut input).unwrap();
    input.trim().parse().unwrap()
}

fn random(board: &[char; 9]) -> usize {
    loop {
        let idx = rand::random_range(0..9);
        if board[idx] == ' ' {
            return idx;
        }
    }
}

fn main() {
    type Solver = Box<dyn FnMut(&[char; 9]) -> usize>;
    let opponent: Solver = match std::env::args().nth(1) {
        Some(file) => {
            if file.ends_with(".ts") {
                panic!("Compile to .js first!")
            } else if file.ends_with(".js") {
                let context = quick_js::Context::new().unwrap();
                context
                    .add_callback("print", |value: quick_js::Arguments| {
                        for arg in value.into_vec() {
                            println!("{:?}", arg)
                        }
                    })
                    .unwrap();
                context
                    .eval(&std::fs::read_to_string(file).unwrap())
                    .unwrap();
                Box::new(move |board| {
                    context
                        .eval_as::<i32>(&format!("move({:?})", String::from_iter(board.iter())))
                        .unwrap() as _
                })
            } else if file.ends_with(".rb") {
                #[cfg(feature = "ruby")]
                {
                use rutie::{Integer, Object, VM};
                VM::init();
                VM::eval(&std::fs::read_to_string(file).unwrap()).unwrap();
                Box::new(move |board| {
                    VM::eval(&format!("move({:?})", String::from_iter(board.iter())))
                        .unwrap()
                        .try_convert_to::<Integer>()
                        .unwrap()
                        .to_u32() as _
                })
                }
                #[cfg(not(feature = "ruby"))]
                panic!("Enable ruby flag to use ruby")
            } else if file.ends_with(".sh") {
                let mut interpreter = flash::interpreter::Interpreter::new();
                interpreter
                    .execute(&std::fs::read_to_string(file).unwrap())
                    .unwrap();
                Box::new(move |board| {
                    interpreter
                        .execute(&format!(
                            "move {}",
                            board.map(|c| format!("\"{}\"", c)).join(" ")
                        ))
                        .unwrap() as _
                })
            } else if file.ends_with(".c") || file.ends_with(".ml") {
                panic!("Compile to a shared library first!")
            } else if file.ends_with(".so") {
                let lib = Box::leak(Box::new(unsafe { libloading::Library::new(file).unwrap() }));
                let func: libloading::Symbol<
                    unsafe extern "C" fn(&std::ffi::CStr) -> std::ffi::c_int,
                > = unsafe { lib.get(b"move").unwrap() };
                Box::new(move |board| {
                    let _ = lib;
                    unsafe {
                        func(
                            std::ffi::CString::new(String::from_iter(board.iter()))
                                .unwrap()
                                .as_c_str(),
                        ) as _
                    }
                })
            } else {
                panic!("Unknown file type for {}", file);
            }
        }
        None => Box::new(human),
    };

    print_board(
        &(0..9)
            .map(|i| char::from_digit(i, 10).unwrap())
            .collect::<Vec<_>>()
            .try_into()
            .unwrap(),
    );

    let mut board = [' '; 9];

    struct Player {
        ch: char,
        history: Vec<usize>,
        function: Solver,
    }
    let mut players = [
        Player {
            ch: 'x',
            history: Vec::new(),
            function: Box::new(random),
        },
        Player {
            ch: 'o',
            history: Vec::new(),
            function: opponent,
        },
    ];

    let winner = 'outer: loop {
        for player in &mut players {
            let idx = (player.function)(&board);
            if board[idx] != ' ' {
                println!(
                    "Cheating! Tried to replace {} at {} with {}",
                    board[idx], idx, player.ch
                );
                return;
            }

            board[idx] = player.ch;

            player.history.push(idx);
            if player.history.len() > 3 {
                board[player.history.remove(0)] = ' ';
            }

            // Make it nicer
            if player.history.len() >= 3 {
                board[player.history[0]] = board[player.history[0]].to_ascii_uppercase();
            }

            print_board(&board);
            match win(&board) {
                ' ' => (),
                winner => break 'outer winner,
            }
        }
    };
    println!("Winner: {}", winner);
}
