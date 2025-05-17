# PowerShell Script to Automate J.A.R.V.I.S.-like AI Setup in Python

# Set execution policy to allow scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Create a new directory for the AI assistant
$aiPath = "D:\JarvisAI"
if (!(Test-Path -Path $aiPath)) {
    New-Item -ItemType Directory -Path $aiPath
}

# Navigate to the directory
Set-Location -Path $aiPath

# Check if Python is installed
$pythonCheck = python --version 2>$null
if (-not $?) {
    Write-Host "Python is not installed. Please install Python and rerun the script." -ForegroundColor Red
    exit
}

# Create a virtual environment
python -m venv jarvis_env

# Activate the virtual environment
Set-ExecutionPolicy Unrestricted -Scope Process
.\jarvis_env\Scripts\Activate

# Install required dependencies
Write-Host "Installing required Python libraries..." -ForegroundColor Green
pip install --upgrade pip
pip install openai speechrecognition pyttsx3 nltk requests beautifulsoup4 pyaudio pywhatkit wikipedia
pip install openai speechrecognition pyttsx3 nltk requests beautifulsoup4 pyaudio pywhatkit wikipedia gtts smtplib pyjokes


# Define the Python script content
$pythonScript = @"
import speech_recognition as sr
import pyttsx3
import datetime
import wikipedia
import pywhatkit

def speak(text):
    engine = pyttsx3.init()
    engine.say(text)
    engine.runAndWait()

def recognize_speech():
    recognizer = sr.Recognizer()
    with sr.Microphone() as source:
        print("Listening...")
        recognizer.adjust_for_ambient_noise(source)
        audio = recognizer.listen(source)
    try:
        command = recognizer.recognize_google(audio).lower()
        print(f"User said: {command}")
        return command
    except sr.UnknownValueError:
        speak("Sorry, I did not understand that.")
        return ""

def ai_assistant(ai_name="Jarvis"):
    speak(f"Hello, I am {ai_name}. How can I assist you?")
    while True:
        command = recognize_speech()
        if "time" in command:
            speak(datetime.datetime.now().strftime("%I:%M %p"))
        elif "search" in command:
            query = command.replace("search", "").strip()
            speak(f"Searching Wikipedia for {query}")
            results = wikipedia.summary(query, sentences=2)
            speak(results)
        elif "play" in command:
            song = command.replace("play", "").strip()
            speak(f"Playing {song}")
            pywhatkit.playonyt(song)
        elif "exit" in command:
            speak("Goodbye!")
            break
        else:
            speak("I am not sure how to respond to that.")

if __name__ == "__main__":
    ai_name = input("Enter AI name (default: Jarvis): ") or "Jarvis"
    ai_assistant(ai_name)
"@

# Save the Python script
$pythonFilePath = "$aiPath\ai_assistant.py"
Set-Content -Path $pythonFilePath -Value $pythonScript

# Open Python IDLE and automatically type out the script
Start-Process "pythonw.exe" -ArgumentList "-m idlelib.idle $pythonFilePath"

Write-Host "Setup Complete! Python script has been opened in IDLE. Please review and run it manually." -ForegroundColor Green
