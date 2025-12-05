# 🤖 AI ChatBot - BAT Scripts Guide

This directory contains three convenient batch scripts for testing the AI ChatBot functionality.

---

## 📋 Available Scripts

### 1. `run_chatbot_test.bat` - Full-Featured Menu

**Features:**
- Interactive menu system
- Multiple test modes
- Backend status checking
- User-friendly interface

**Usage:**
```bash
# Simply double-click the file or run:
run_chatbot_test.bat
```

**Menu Options:**
```
1) Interactive chat (recommended)
   - Real-time conversation with AI

2) Automated test
   - Runs 5 predefined test messages

3) Single message test
   - Test a custom message

4) Check backend status
   - Verify backend connection

5) Exit
```

---

### 2. `start_interactive_chat.bat` - Quick Interactive Chat

**Best for:** Quick chatting without menu navigation

**Features:**
- Auto-detects Python
- Auto-installs requests library if needed
- Directly starts interactive chat
- Simple and fast

**Usage:**
```bash
# Double-click or run:
start_interactive_chat.bat
```

Then type your messages and chat with AI!

**Example Conversation:**
```
🤖 AI ChatBot:
   Hello! I am an AI customer service assistant...

👤 You: What dishes do you have?
⏳ Waiting for AI response...
🤖 AI ChatBot:
   We have a rich selection of dishes...

👤 You: exit
```

---

### 3. `start_backend_and_test.bat` - Full Startup

**Best for:** Complete setup from scratch

**Features:**
- Starts backend service automatically
- Waits for backend to initialize
- Automatically launches test tool
- All in one click!

**Usage:**
```bash
# Double-click or run:
start_backend_and_test.bat
```

**What it does:**
1. ✅ Starts backend on port 8080 (in new window)
2. ✅ Waits 5 seconds for backend to initialize
3. ✅ Launches interactive chat tool
4. ✅ You can start chatting immediately!

**Note:** The backend window will stay open. Close it to stop the backend.

---

## 🚀 Quick Start Guide

### Option A: One-Click Full Startup (Recommended)

```bash
# Simply double-click:
start_backend_and_test.bat
```

Wait ~10 seconds, then start chatting!

### Option B: Manual Backend + Script Menu

```bash
# Terminal 1: Start backend manually
cd backend
mvn spring-boot:run

# Terminal 2: Run script menu
run_chatbot_test.bat
```

### Option C: Quick Chat Only

```bash
# Backend must be running!
start_interactive_chat.bat
```

---

## 📊 System Requirements

- Windows OS (XP, Vista, 7, 8, 10, 11)
- Python 3.6+ (added to PATH)
- Java 17+ (for backend)
- Maven 3.9+ (for building backend)

---

## ⚙️ Technical Details

### Encoding
All scripts are **UTF-8 encoded** for proper Chinese character display on Windows 10+

### Character Set
```batch
chcp 65001 >nul  # Switches to UTF-8 code page
```

### Backend Port
Default: **8080**

If port is in use:
```batch
# Find process using port 8080
netstat -ano | findstr :8080

# Kill the process (replace PID)
taskkill /PID <PID> /F
```

---

## 🧪 Test Modes Explained

### Interactive Chat Mode

```bash
run_chatbot_test.bat  # Choose option 1
# or
start_interactive_chat.bat
```

**Features:**
- Real-time conversation
- Type `exit` to quit
- Type `help` for commands
- Type `status` to check backend
- Multiple turns supported

**Example:**
```
👤 You: Hello
🤖 AI: Hello! Welcome to our food delivery system!

👤 You: What's the shipping time?
🤖 AI: We typically deliver within 30 minutes to 1 hour...

👤 You: exit
Thank you for using AI ChatBot.
```

---

### Automated Test Mode

```bash
run_chatbot_test.bat  # Choose option 2
```

**Tests 5 predefined messages:**
1. "Hello"
2. "What dishes do you have?"
3. "How long for delivery?"
4. "How do I place an order?"
5. "Thank you"

**Output:**
```
Running automated tests...

─────────────────────────
User [1/5]: Hello
AI: Hello! Welcome to our food delivery system!
─────────────────────────
User [2/5]: What dishes do you have?
AI: We have a rich selection of dishes...
```

---

### Single Message Test

```bash
run_chatbot_test.bat  # Choose option 3
# Then type your message
```

**Quick test of a single message:**
```
Enter your message: Do you have vegan options?
Sending message...
AI: Yes, we have vegan options available...
```

---

## ✅ Verification Checklist

- [ ] Python is installed (`python --version` shows version)
- [ ] requests library is available (`pip list` shows requests)
- [ ] Backend is running on port 8080
- [ ] Script can connect to backend
- [ ] AI responses are received
- [ ] Multiple turns work
- [ ] Can exit cleanly

---

## 🐛 Troubleshooting

### Problem: "Python not found"

**Solution:**
1. Install Python 3.6+ from https://python.org
2. During installation, check "Add Python to PATH"
3. Restart your computer
4. Try again

### Problem: "requests library not found"

**Solution:**
```bash
pip install requests
# or
python -m pip install requests
```

The script will try to install it automatically.

### Problem: "Cannot connect to backend"

**Solution:**
```bash
# Check if backend is running
curl http://localhost:8080/api/chatbot/status

# If not, start it:
cd backend
mvn spring-boot:run
```

### Problem: "Port 8080 already in use"

**Solution:**
```bash
# Find process using port 8080
netstat -ano | findstr :8080

# Kill the process (replace <PID>)
taskkill /PID <PID> /F

# Or use different port in backend config
```

### Problem: Chinese characters not displaying correctly

**Solution:**
- Scripts are UTF-8 encoded (uses `chcp 65001`)
- Requires Windows 10 or later for proper display
- Use Windows Terminal instead of CMD for better compatibility

---

## 📞 Support

### Quick Help

```bash
# Show Python version
python --version

# Show pip version
pip --version

# List installed packages
pip list

# Test backend connection
curl http://localhost:8080/api/chatbot/status

# Test Python requests library
python -c "import requests; print(requests.__version__)"
```

### Log Files

Backend logs are usually in:
```
backend/target/logs/meal-order-system.log
```

### Full Documentation

See:
- `START_HERE.md` - Quick start guide
- `QUICK_TEST.md` - Detailed test guide
- `../docs/AI客服快速启动.md` - Complete startup guide

---

## 🎯 Success Indicators

When everything is working:

1. ✅ Script launches without errors
2. ✅ "Backend service OK" message appears
3. ✅ AI ChatBot welcome message displays
4. ✅ You can type messages
5. ✅ AI responses appear within 3 seconds
6. ✅ Can have multiple turns
7. ✅ `exit` command closes cleanly

---

## 📊 Expected Behavior

### Successful Test

```
========================================================================
                    AI ChatBot Test - Startup Script
========================================================================

[1/3] Checking Python installation...
      OK - Python found

[2/3] Checking Python requests library...
      OK - requests library found

[3/3] Checking backend service...
      OK - Backend is running on port 8080

========================================================================
                  AI ChatBot Interactive Test Tool
========================================================================

Choose test mode:

  1) Interactive chat (recommended)
  2) Automated test (5 predefined messages)
  3) Single message test
  4) Check backend status
  5) Exit

Enter your choice (1-5): 1

========================================================================
Starting interactive chat mode (type 'exit' to quit)...
========================================================================

🤖 AI ChatBot:
   Hello! I'm an AI customer service assistant...

👤 You: _
```

---

## 💡 Tips & Tricks

### Testing Multiple Messages

```bash
# Type messages one by one
👤 You: Hello
👤 You: What dishes?
👤 You: How long delivery?
👤 You: exit
```

### Testing Error Handling

Try these edge cases:
- Empty message (just press Enter)
- Very long message (>500 characters)
- Special characters
- Repeated questions

### Performance Testing

```bash
run_chatbot_test.bat  # Choose option 2
# Runs 5 messages automatically
# Check response times
```

### Network Testing

```bash
run_chatbot_test.bat  # Choose option 4
# Checks backend connection status
```

---

## 🎓 Learning Resources

### About the Scripts

| File | Purpose | Best For |
|------|---------|----------|
| `run_chatbot_test.bat` | Full menu system | Learning all features |
| `start_interactive_chat.bat` | Quick chat | Fast testing |
| `start_backend_and_test.bat` | Complete setup | First-time users |

### About the Code

Backend implementation:
- `../backend/src/main/java/com/meal/order/controller/ChatBotController.java`
- `../backend/src/main/java/com/meal/order/service/impl/ChatBotServiceImpl.java`

Frontend implementation:
- `../frontend-user/src/components/ChatBot.vue`
- `../frontend-user/src/services/chatbotApi.ts`

Test script:
- `chatbot_test.py` (Python)

---

## 🚀 Next Steps

1. **Try one-click startup:**
   ```bash
   start_backend_and_test.bat
   ```

2. **Have a conversation:**
   ```
   👤 You: Hello
   🤖 AI: [Response]
   ```

3. **Explore features:**
   - Try different questions
   - Test edge cases
   - Check response times

4. **Review code:**
   - Read backend implementation
   - Check frontend components
   - Understand test script

---

**Ready to chat with AI?** 🎯

```bash
Double-click: start_interactive_chat.bat
```

---

**Last Updated:** 2025-12-05
**Encoding:** UTF-8
**Language:** English
**For:** Windows OS
