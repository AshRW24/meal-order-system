#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
🤖 AI 客服交互测试脚本
直接与 DeepSeek AI 客服进行实时对话

使用方法:
    python chatbot_test.py

然后在终端中输入消息，与 AI 客服进行对话

依赖:
    pip install requests
"""

import requests
import json
import sys
from typing import Dict, Any
from datetime import datetime

# ==================== 配置 ====================

# 后端 API 地址
BACKEND_URL = "http://localhost:8080/api"
CHATBOT_API = f"{BACKEND_URL}/chatbot/message"
CHATBOT_STATUS = f"{BACKEND_URL}/chatbot/status"
CHATBOT_WELCOME = f"{BACKEND_URL}/chatbot/welcome"

# 颜色定义（for 美观输出）
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

# ==================== 核心函数 ====================

def print_header():
    """打印欢迎信息"""
    print(f"\n{Colors.BOLD}{Colors.CYAN}")
    print("╔═══════════════════════════════════════════════════╗")
    print("║                                                   ║")
    print("║         🤖 外卖订餐系统 - AI 客服测试工具          ║")
    print("║                                                   ║")
    print("║        DeepSeek AI + 后端集成测试                 ║")
    print("║                                                   ║")
    print("╚═══════════════════════════════════════════════════╝")
    print(f"{Colors.ENDC}\n")


def check_backend_status() -> bool:
    """检查后端是否在线"""
    try:
        response = requests.get(CHATBOT_STATUS, timeout=5)
        if response.status_code == 200:
            data = response.json()
            if data.get('code') == 200:
                return True
    except Exception as e:
        print(f"{Colors.RED}❌ 后端连接失败: {e}{Colors.ENDC}")
    return False


def get_welcome_message() -> str:
    """获取 AI 欢迎语"""
    try:
        response = requests.get(CHATBOT_WELCOME, timeout=5)
        if response.status_code == 200:
            data = response.json()
            if data.get('code') == 200:
                return data.get('data', {}).get('message', '您好！')
    except Exception as e:
        print(f"{Colors.YELLOW}⚠️  无法获取欢迎语: {e}{Colors.ENDC}")

    return "您好！我是 AI 客服助手，有什么可以帮您的吗？"


def send_message_to_chatbot(message: str) -> Dict[str, Any]:
    """
    发送消息到 AI 客服

    Args:
        message: 用户消息

    Returns:
        返回结果字典，包含 success、message 或 error
    """
    try:
        payload = {
            "message": message,
            "conversationId": None
        }

        headers = {
            "Content-Type": "application/json"
        }

        response = requests.post(
            CHATBOT_API,
            json=payload,
            headers=headers,
            timeout=30
        )

        if response.status_code == 200:
            data = response.json()
            if data.get('code') == 200:
                ai_message = data.get('data', {}).get('message', '')
                return {
                    'success': True,
                    'message': ai_message,
                    'timestamp': data.get('data', {}).get('timestamp')
                }
            else:
                return {
                    'success': False,
                    'error': data.get('msg', '未知错误')
                }
        else:
            return {
                'success': False,
                'error': f"HTTP {response.status_code}: {response.text}"
            }

    except requests.exceptions.Timeout:
        return {
            'success': False,
            'error': '请求超时（>30秒），可能是 AI 处理缓慢或网络问题'
        }
    except requests.exceptions.ConnectionError:
        return {
            'success': False,
            'error': '无法连接到后端服务器，请确保后端正在运行'
        }
    except Exception as e:
        return {
            'success': False,
            'error': f"请求失败: {str(e)}"
        }


def format_time(timestamp: int) -> str:
    """格式化时间戳"""
    try:
        dt = datetime.fromtimestamp(timestamp / 1000)
        return dt.strftime("%H:%M:%S")
    except:
        return ""


def print_divider():
    """打印分隔线"""
    print(f"{Colors.BLUE}{'─' * 55}{Colors.ENDC}")


def main():
    """主程序"""
    print_header()

    # 检查后端状态
    print(f"{Colors.YELLOW}🔍 检查后端服务状态...{Colors.ENDC}")
    if not check_backend_status():
        print(f"{Colors.RED}❌ 后端服务未运行！{Colors.ENDC}")
        print(f"\n{Colors.YELLOW}请启动后端:${Colors.ENDC}")
        print(f"  cd backend")
        print(f"  mvn spring-boot:run\n")
        return

    print(f"{Colors.GREEN}✅ 后端服务正常{Colors.ENDC}\n")

    # 获取欢迎语
    print(f"{Colors.CYAN}🤖 AI 客服:{Colors.ENDC}")
    welcome_msg = get_welcome_message()
    print(f"   {welcome_msg}\n")

    print_divider()
    print(f"{Colors.YELLOW}💡 命令:{Colors.ENDC}")
    print(f"  • 输入消息进行对话")
    print(f"  • 输入 'exit' 或 'quit' 退出")
    print(f"  • 输入 'help' 查看帮助")
    print_divider()
    print()

    # 交互循环
    message_count = 0
    while True:
        try:
            # 获取用户输入
            user_input = input(f"{Colors.GREEN}👤 您:{Colors.ENDC} ").strip()

            if not user_input:
                continue

            # 处理特殊命令
            if user_input.lower() in ['exit', 'quit', 'q']:
                print(f"\n{Colors.CYAN}再见！感谢使用 AI 客服。{Colors.ENDC}\n")
                break

            if user_input.lower() == 'help':
                print_help()
                continue

            if user_input.lower() == 'status':
                check_and_print_status()
                continue

            # 发送消息到 AI 客服
            print(f"{Colors.YELLOW}⏳ 等待 AI 回复...{Colors.ENDC}")

            result = send_message_to_chatbot(user_input)

            if result['success']:
                ai_message = result['message']
                timestamp = result.get('timestamp')
                time_str = f" [{format_time(timestamp)}]" if timestamp else ""

                print(f"{Colors.CYAN}🤖 AI 客服:{Colors.ENDC}")
                print(f"   {ai_message}{time_str}\n")

                message_count += 1

            else:
                print(f"{Colors.RED}❌ 错误: {result['error']}{Colors.ENDC}\n")

        except KeyboardInterrupt:
            print(f"\n\n{Colors.CYAN}中断\n{Colors.ENDC}")
            break
        except Exception as e:
            print(f"{Colors.RED}❌ 发生错误: {str(e)}{Colors.ENDC}\n")


def print_help():
    """打印帮助信息"""
    print(f"\n{Colors.BOLD}📖 命令帮助:{Colors.ENDC}")
    print(f"  exit, quit, q  - 退出程序")
    print(f"  help           - 显示此帮助信息")
    print(f"  status         - 检查服务状态")
    print()


def check_and_print_status():
    """检查并打印服务状态"""
    print()
    if check_backend_status():
        print(f"{Colors.GREEN}✅ 后端服务: 正常{Colors.ENDC}")
    else:
        print(f"{Colors.RED}❌ 后端服务: 离线{Colors.ENDC}")
    print()


# ==================== 测试用例 ====================

def run_test_cases():
    """运行自动化测试"""
    print(f"\n{Colors.BOLD}🧪 运行自动化测试...{Colors.ENDC}\n")

    test_messages = [
        "你好",
        "有什么菜品？",
        "配送要多久？",
        "订单怎么下？",
        "谢谢"
    ]

    print_divider()
    for i, message in enumerate(test_messages, 1):
        print(f"{Colors.GREEN}👤 用户 [{i}/{len(test_messages)}]:{Colors.ENDC} {message}")

        result = send_message_to_chatbot(message)

        if result['success']:
            print(f"{Colors.CYAN}🤖 AI 客服:{Colors.ENDC} {result['message']}")
        else:
            print(f"{Colors.RED}❌ 错误:{Colors.ENDC} {result['error']}")

        print_divider()


# ==================== 入口 ====================

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(
        description='🤖 AI 客服测试脚本',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
示例:
  python chatbot_test.py              # 交互模式
  python chatbot_test.py --test       # 自动化测试
  python chatbot_test.py --message "你好"  # 单次测试
        """
    )

    parser.add_argument('--test', action='store_true', help='运行自动化测试')
    parser.add_argument('--message', type=str, help='发送单条消息')
    parser.add_argument('--backend-url', type=str, default='http://localhost:8080/api',
                        help='后端 API 地址')

    args = parser.parse_args()

    # 更新后端 URL
    if args.backend_url:
        CHATBOT_API = f"{args.backend_url}/chatbot/message"
        CHATBOT_STATUS = f"{args.backend_url}/chatbot/status"
        CHATBOT_WELCOME = f"{args.backend_url}/chatbot/welcome"

    try:
        if args.test:
            # 自动化测试
            run_test_cases()
        elif args.message:
            # 单条消息测试
            print(f"{Colors.GREEN}👤 发送消息:{Colors.ENDC} {args.message}")
            result = send_message_to_chatbot(args.message)
            if result['success']:
                print(f"{Colors.CYAN}🤖 AI 客服:{Colors.ENDC} {result['message']}")
            else:
                print(f"{Colors.RED}❌ 错误:{Colors.ENDC} {result['error']}")
        else:
            # 交互模式
            main()
    except KeyboardInterrupt:
        print(f"\n\n{Colors.CYAN}已退出\n{Colors.ENDC}")
    except Exception as e:
        print(f"{Colors.RED}❌ 致命错误: {str(e)}{Colors.ENDC}")
        sys.exit(1)
