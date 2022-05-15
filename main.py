def new_game():
    guesses = []
    correct_guesses = 0
    question_num = 1

    for key in questions:
        print("-------------------------------------------")
        print(key)
        for i in options[question_num - 1]:
            print(i)
        guess = input("Enter (A, B, C, D): ").upper()
        guesses.append(guess)
        correct_guesses += check_answer(questions.get(key),guess)

        question_num += 1

    display_score(correct_guesses, guesses)
#___________________________

def check_answer(answer, guess):
    if answer == guess:
        print("Bari keldi! Well done!")
        return 1
    else:
        print("WRONG, but Berilme! Do not give up!")
        return 0


#___________________________

def display_score(correct_guesses, guesses):
    print("___________________________")
    print("Results: ")
    print("___________________________")

    print("Answers: ", end=" ")
    for i in questions:
        print(questions.get(i), end=" ")
    print()

    print("Guesses: ", end=" ")
    for i in guesses:
        print(i, end=" ")
    print()

    score = int(correct_guesses/len(questions)*100)
    print("Your Score is: "+str(score) + "%")

#___________________________

def play_again():
    response = input("Do you want to take the quiz again (Yes or No):  ").lower()
    if "yes" in response:
        return True
    else:
        return False

#___________________________









questions = {"When did Kazakhstan proclaim independence?: ": "A",
            "Which country is to the north of Kazakhstan?: ": "B",
            "Which lake is to the southwest of Kazakhstan?: ":"D",
            "What is the capital of Kazakhstan?: ": "C",
            "What is the currency in Kazakhstan?: ": "A",
            "What is the official language in Kazakhstan?: ": "D",
            "Kazakhstan is thought to be the original home of what fruit?: ": "C",
            "What city in Kazakhstan has the first functioning space launch facility?: ": "C"}

options = [["A. December 16 1991", "B. August 25 1993", "C. August 30 1995","D. December 1 1990"],
           ["A. China", "B. Russia", "C. Kyrgyzstan", "D. Uzbekistan"],
           ["A. Aral lake", "B. Ontario lake", "C. Dead Sea", "D. Kaspian Sea"],
           ["A. Almaty", "B. Akmola", "C. Nur-Sultan", "D. Taraz"],
           ["A. Tenge", "B. Us dollar", "C. Ruble", "D. Som"],
           ["A. Russian", "B. English", "C. Turkish", "D. Kazakh"],
           ["A. Orange", "B. kiwi", "C. Apple", "D. Pear"],
           ["A. Atyrau", "B. Chernobyl", "C. Baikonur", "D. Karaganda"]]


new_game()

while play_again():

    new_game()



print("Thanks for the quiz! I hope you learned something new about Kazakhstan!")





