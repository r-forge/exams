<script>

/* update total correct if #webex-total_correct exists */
update_total_correct = function() {
  console.log("webex: update total_correct");

  //var t = document.getElementsByClassName("webex-total_correct");
  //for (var i = 0; i < t.length; i++) {
  //  p = t[i].parentElement;
  //  var correct = p.getElementsByClassName("webex-correct").length;
  //  var solvemes = p.getElementsByClassName("webex-solveme").length;
  //  var radiogroups = p.getElementsByClassName("webex-radiogroup").length;
  //  var selects = p.getElementsByClassName("webex-select").length;
  //  /* no specific class on input node, thus searching via query selector */
  //  var checkboxgroups = p.querySelectorAll("div[class=webex-checkboxgroup] input[type=checkbox]").length

  //  t[i].innerHTML = correct + " of " + (solvemes + radiogroups + checkboxgroups + selects) + " correct";
  //}
  document.querySelectorAll(".webex-total_correct").forEach(total => {
    p = total.parentElement;
    var correct = p.getElementsByClassName("webex-correct").length;
    var solvemes = p.getElementsByClassName("webex-solveme").length;
    var radiogroups = p.getElementsByClassName("webex-radiogroup").length;
    var selects = p.getElementsByClassName("webex-select").length;
    /* no specific class on input node, thus searching via query selector */
    var checkboxgroups = p.querySelectorAll("div[class=webex-checkboxgroup] input[type=checkbox]").length

    total.innerHTML = correct + " of " + (solvemes + radiogroups + checkboxgroups + selects) + " correct";
  });
}

/* webex-solution button toggling function */
b_func = function() {
  console.log("webex: toggle hide");

  var cl = this.parentElement.classList;
  if (cl.contains("open")) {
    cl.remove("open");
  } else {
    cl.add("open");
  }
}

/* check answers */
check_func = function() {
  console.log("webex: check answers");

  var cl = this.parentElement.classList;
  if (cl.contains("unchecked")) {
    cl.remove("unchecked");
    this.innerHTML = "Hide Answers";
  } else {
    cl.add("unchecked");
    this.innerHTML = "Show Answers";
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

    let btn = document.createElement("button");
    btn.innerHTML = "Show Answers";
    btn.classList.add("webex-check-button");
    btn.onclick = check_func;
    section.appendChild(btn);

    let spn = document.createElement("span");
    spn.classList.add("webex-total_correct");
    section.appendChild(spn);
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

  /* change to next question if multiple are available */
  function handleNextQuestionClick(group, questions) {
    return async function() {
      let currentPosition = parseInt(group.dataset.currentPosition);
      const questionNum = parseInt(group.dataset.questionNum);
  
      // Hide the current question
      questions[currentPosition].classList.remove("active");
      // Move to the next question index
      currentPosition = (currentPosition + 1) % questionNum;
      // Display the new question
      questions[currentPosition].classList.add("active");
  
      // Update the currentPosition data attribute on the group div
      group.dataset.currentPosition = currentPosition;
    };
  }
  
  document.querySelectorAll(".webex-group").forEach(group => {
    const questions = Array.from(group.querySelectorAll(".webex-question"));
    const questionNum = questions.length;
  
    let currentPosition = parseInt(group.getAttribute("data-start-position")) || Math.floor(Math.random() * questionNum);
  
    // Show the default question for each group
    questions[currentPosition].classList.add("active");
    console.log(currentPosition + " set active");
  
    // Store questionNum and currentPosition as data attributes on the group div
    group.dataset.questionNum = questionNum;
    group.dataset.currentPosition = currentPosition;
  
    const nextButton = document.createElement("button");
    nextButton.classList.add("webex-next-button");
    nextButton.textContent = "Next Question";
    nextButton.addEventListener("click", handleNextQuestionClick(group, questions));
    group.appendChild(nextButton);
  });


  update_total_correct();
}

</script>
