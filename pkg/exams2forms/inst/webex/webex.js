<script>

/* definition of content for the buttons */
const webex_buttons = {check_hidden:          "<b>&check;</b>",
                       check_hidden_alt:      "Check answer",
                       check_shown:           "<b>&lsh;</b>",
                       check_shown_alt:       "Hide check",
                       check_of_total:        "/",
                       solution:              "<b>&quest;</b>",
                       solution_alt:          "Correct solution",
                       question_next:         "<b>&#8634;</b>",
                       question_next_alt:     "Next question",
                       question_previous:     "",
                       question_previous_alt: ""}


/* update total correct if #webex-total_correct exists */
update_total_correct = function() {
  console.log("webex: update total_correct");

  document.querySelectorAll(".webex-total_correct").forEach(total => {
    p = total.closest(".webex-box");
    var correct = p.getElementsByClassName("webex-correct").length;
    var solvemes = p.getElementsByClassName("webex-solveme").length;
    var radiogroups = p.getElementsByClassName("webex-radiogroup").length;
    var selects = p.getElementsByClassName("webex-select").length;
    /* no specific class on input node, thus searching via query selector */
    var checkboxgroups = p.querySelectorAll("div[class=webex-checkboxgroup] input[type=checkbox]").length

    /* show number of correct / total number of answers */
    total.innerHTML = correct + "&nbsp;" + webex_buttons.check_of_total + "&nbsp;" + (solvemes + radiogroups + checkboxgroups + selects);
  });
}

/* webex-solution button toggling function */
b_func = function() {
  console.log("webex: toggle hide");

    alert("Reto: was macht die funktion genau?");
  var cl = this.parentElement.classList;
  if (cl.contains("open")) {
    cl.remove("open");
  } else {
    cl.add("open");
  }
}

/* check answers */
check_func = function() {
  console.log("webex: check answer");

  //var cl = this.parentElement.classList;
  var cl = this.closest(".webex-box").classList;
  if (cl.contains("unchecked")) {
    cl.remove("unchecked");
    this.innerHTML = webex_buttons.check_shown; //"Hide check";
    this.setAttribute("title", webex_buttons.check_shown_alt);
  } else {
    cl.add("unchecked");
    this.innerHTML = webex_buttons.check_hidden; //"Check answer";
    this.setAttribute("title", webex_buttons.check_hidden_alt);
  }
}

/* Show/hide correct solution */
solution_func = function() {
  console.log("webex: show/hide solution");

  var div = this.closest(".webex-question").querySelector(".webex-solution");
  var cl = div.classList;

  if (cl.contains("visible")) {
    cl.remove("visible");
    //this.innerHTML = "Show solution";
  } else {
    cl.add("visible");
    //this.innerHTML = "Hide solution";
  }
}

/* function for checking solveme answers */
solveme_func = function(e) {
  console.log("webex: check solveme");

  var real_answers = JSON.parse(this.dataset.answer);
  var my_answer = this.value;
  var cl = this.classList;
  if (cl.contains("ignorecase")) {
    my_answer = my_answer.toLowerCase();
  }
  if (cl.contains("nospaces")) {
    my_answer = my_answer.replace(/ /g, "")
  }

  if (my_answer == "") {
    cl.remove("webex-correct");
    cl.remove("webex-incorrect");
  } else if (real_answers.includes(my_answer)) {
    cl.add("webex-correct");
    cl.remove("webex-incorrect");
  } else {
    cl.add("webex-incorrect");
    cl.remove("webex-correct");
  }

  // match numeric answers within a specified tolerance
  if (this.dataset.tol > 0){
    my_answer = my_answer.replace(/,/g, "."); //also allow decimal comma
    var tol = JSON.parse(this.dataset.tol);
    var matches = real_answers.map(x => Math.abs(x - my_answer) < tol + 0.00000000000001)
    if (matches.reduce((a, b) => a + b, 0) > 0) {
      cl.add("webex-correct");
    } else {
      cl.remove("webex-correct");
    }
  }

  // added regex bit
  if (cl.contains("regex")){
    answer_regex = RegExp(real_answers.join("|"))
    if (answer_regex.test(my_answer)) {
      cl.add("webex-correct");
    }
  }

  update_total_correct();
}

/* function for checking select answers */
select_func = function(e) {
  console.log("webex: check select");

  var cl = this.classList

  /* add style */
  cl.remove("webex-incorrect");
  cl.remove("webex-correct");
  if (this.value == "answer") {
    cl.add("webex-correct");
  } else if (this.value != "blank") {
    cl.add("webex-incorrect");
  }

  update_total_correct();
}

/* function for checking radiogroups answers */
radiogroups_func = function(e) {
  console.log("webex: check radiogroups");

  var checked_button = document.querySelector("input[name=" + this.id + "]:checked");
  var cl = checked_button.parentElement.classList;
  var labels = checked_button.parentElement.parentElement.children;

  /* get rid of styles */
  for (i = 0; i < labels.length; i++) {
    labels[i].classList.remove("webex-incorrect");
    labels[i].classList.remove("webex-correct");
  }

  /* add style */
  if (checked_button.value == "answer") {
    cl.add("webex-correct");
  } else {
    cl.add("webex-incorrect");
  }

  update_total_correct();
}


/* function for checking checkboxgroups answers */
checkboxgroups_func = function(e) {
  console.log("webex: check checkboxgroups");

  /* list of all answer elements (correct and incorrect) */
  var inputs = document.querySelectorAll("div[id='" + this.id + "'] input")

  /* setting class for correct/incorrect answers */
  inputs.forEach(function(input) {
      var label = input.parentNode
      if ((input.checked && input.value == "answer") || (!input.checked && input.value == "")) {
          //input.setAttribute("class", "webex-correct")
          label.setAttribute("class", "webex-correct")
      } else {
          label.setAttribute("class", "webex-incorrect")
      }
  });

  update_total_correct();
}

/* shuffling array (thanks to stack overflow)
 * If argument x is an integer we create an integer sequence
 * from 0, 1, ..., (x - 1) and return a shuffled version. If
 * the input is an array, we simply shuffle it */
shuffle_array = function(x) {
   if (Number.isInteger(x) && !isNaN(x)) {
     x = Array.from({length: x}, (v, i) => i);
   }
   let shuffled = x.map(value => ({ value, sort: Math.random() }))
        .sort((a, b) => a.sort - b.sort).map(({ value }) => value)
   return shuffled;
}

/* ---------------------------------------------------------
 * ---------------------------------------------------------
 * --------------------------------------------------------- */
window.onload = function() {
  console.log("webex onload");

  /* set up solution buttons */
  document.querySelectorAll("button").forEach(button => {
    if (button.parentElement.classList.contains("webex-solution")) {
      button.onclick = b_func;
    }
  });

  /* setting up buttons and actions to show/hide answers */
  document.querySelectorAll(".webex-check").forEach(section => {
    section.classList.add("unchecked");

    /* bootstrap 3x grid */
    let div_row = document.createElement("div");
    div_row.setAttribute("class", "row row-buttons");
    let div_col1 = document.createElement("div");
    div_col1.setAttribute("class", "col-xs-6 text-left");
    let div_col2 = document.createElement("div");
    div_col2.setAttribute("class", "col-xs-6 text-right");

    /* appending columns to row, insert into 'section' */
    div_row.appendChild(div_col1);
    div_row.appendChild(div_col2);
    section.appendChild(div_row);
      
    /* button to _check_ if answers given are correct */
    let btn_check = document.createElement("button");
    btn_check.innerHTML = webex_buttons.check_hidden;  // "Check answer";
    btn_check.setAttribute("class", "webex-button webex-button-check");
    btn_check.setAttribute("title", webex_buttons.check_hidden_alt);
    btn_check.onclick = check_func;
    div_col1.appendChild(btn_check);

    /* span to show current number of points (when _check_ active) */
    let spn = document.createElement("span");
    spn.classList.add("webex-total_correct");
    div_col1.appendChild(spn);

    /* button to show the _solution_ */
    let btn_solution = document.createElement("button");
    btn_solution.innerHTML = webex_buttons.solution; // "Correct answer";
    btn_solution.setAttribute("class", "webex-button webex-button-solution");
    btn_solution.setAttribute("title", webex_buttons.solution_alt);
    btn_solution.onclick = solution_func;
    div_col2.appendChild(btn_solution);

  });

  /* set up webex-solveme inputs */
  document.querySelectorAll(".webex-solveme").forEach(solveme => {
    solveme.setAttribute("autocomplete","off");
    solveme.setAttribute("autocorrect", "off");
    solveme.setAttribute("autocapitalize", "off");
    solveme.setAttribute("spellcheck", "false");
    solveme.value = "";

    /* adjust answer for ignorecase or nospaces */
    if (solveme.classList.contains("ignorecase")) {
      solveme.dataset.answer = solveme.dataset.answer.toLowerCase();
    }
    /* adjust answer for 'no spaces' (ignore spaces) */
    if (solveme.classList.contains("nospaces")) {
      solveme.dataset.answer = solveme.dataset.answer.replace(/ /g, "");
    }

    /* attach checking function */
    solveme.onkeyup = solveme_func;
    solveme.onchange = solveme_func;

    /* adding span to show correct/incorrect icon */
    solveme.insertAdjacentHTML("afterend", " <span class='webex-icon'></span>")
  });

  /* set up radiogroups (single choice questions with display = "buttons") */
  document.querySelectorAll(".webex-radiogroup").forEach(radiogroup => {
    radiogroup.onchange = radiogroups_func;
  });

  /* set up checkboxgroups (multiple choice questions with display = "buttons") */
  document.querySelectorAll(".webex-checkboxgroup").forEach(checkboxgroup => {
    checkboxgroup.onchange = checkboxgroups_func;
  });

  /* set up selects (dropdown menus) */
  document.querySelectorAll(".webex-select").forEach(select => {
    select.onchange = select_func;
    /* append webex-icon for correct/incorrect icons */
    var elem = document.createElement("span")
    elem.classList.add("webex-icon")
    select.parentNode.appendChild(elem)
  });

  /* change to next/previous question if multiple are available */
  function handleQuestionClick(group, questions, step) {
    return async function() {
      /* get question order as integer vector */
      let questionOrder = group.dataset.questionOrder.split(",").map(str => parseInt(str));

      /* current question/position */
      let currentPosition = parseInt(group.dataset.currentPosition);
  
      /* Hide the current question */
      questions.forEach(question => { question.classList.remove("active"); });

      /* Move to the next question index */
      currentPosition = (currentPosition + step) % questionOrder.length;
      if (currentPosition < 0) currentPosition = currentPosition + questionOrder.length

      /* Display the new question */
      console.log("set question " + questionOrder[currentPosition] +
                  " (" + currentPosition + ") as active");
      questions[questionOrder[currentPosition]].classList.add("active");
  
      // Update the currentPosition data attribute on the group div
      group.dataset.currentPosition = currentPosition;
    };
  }

  
  document.querySelectorAll(".webex-group").forEach(group => {
    const questions = Array.from(group.querySelectorAll(".webex-question"));
    const questionOrder = shuffle_array(questions.length);

    /* take start position (if set) or start at 0 */
    const currentPosition = parseInt(group.getAttribute("data-start-position")) || 0;

    /* show the default question for each group */
    questions[questionOrder[currentPosition]].classList.add("active");
    console.log("set question " + questionOrder[currentPosition] +
                " (" + currentPosition + ") as active; " + questionOrder);
  
    /* store random order of questions as well as current position */
    group.dataset.questionOrder   = questionOrder;
    group.dataset.currentPosition = currentPosition;

    /* find all webex-question .row-buttons second column (div:last-chidld) and
     * add buttons for next/previous question */
    questions.forEach(question => {
        let div_col2 = question.querySelector(".row-buttons div:last-child");

        let nextButton = document.createElement("button");
        nextButton.setAttribute("class", "webex-button webex-button-next");
        nextButton.setAttribute("title", webex_buttons.question_next_alt);
        nextButton.innerHTML = webex_buttons.question_next; // "Next question";
        nextButton.addEventListener("click", handleQuestionClick(group, questions, 1));

        let previousButton = document.createElement("button");
        previousButton.setAttribute("class", "webex-button webex-button-previous");
        previousButton.setAttribute("title", webex_buttons.question_previous_alt);
        previousButton.innerHTML = webex_buttons.question_previous; // "Previous question";
        previousButton.addEventListener("click", handleQuestionClick(group, questions, -1));

        if (webex_buttons.question_previous.length > 0) div_col2.appendChild(previousButton);
        if (webex_buttons.question_next.length > 0) div_col2.appendChild(nextButton);
    });
  });


  update_total_correct();
}

</script>
