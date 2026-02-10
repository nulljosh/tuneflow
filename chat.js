// AI Chat Widget for Mac Automation Services
// Connects to OpenClaw gateway for live feedback

class ChatWidget {
    constructor() {
        this.messages = [];
        this.isOpen = false;
        this.init();
    }

    init() {
        // Inject chat UI
        const chatHTML = `
            <div id="ai-chat-widget" class="chat-widget">
                <button id="chat-toggle" class="chat-toggle">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                    </svg>
                </button>
                <div id="chat-window" class="chat-window" style="display: none;">
                    <div class="chat-header">
                        <div>
                            <div class="chat-title">AI Feedback</div>
                            <div class="chat-subtitle">Give feedback on this page</div>
                        </div>
                        <button id="chat-close" class="chat-close">×</button>
                    </div>
                    <div id="chat-messages" class="chat-messages"></div>
                    <div class="chat-input-container">
                        <input type="text" id="chat-input" placeholder="Type your feedback..." />
                        <button id="chat-send">Send</button>
                    </div>
                </div>
            </div>
        `;

        document.body.insertAdjacentHTML('beforeend', chatHTML);
        this.attachEventListeners();
        this.addWelcomeMessage();
    }

    attachEventListeners() {
        document.getElementById('chat-toggle').addEventListener('click', () => this.toggleChat());
        document.getElementById('chat-close').addEventListener('click', () => this.toggleChat());
        document.getElementById('chat-send').addEventListener('click', () => this.sendMessage());
        document.getElementById('chat-input').addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.sendMessage();
        });
    }

    toggleChat() {
        this.isOpen = !this.isOpen;
        const window = document.getElementById('chat-window');
        const toggle = document.getElementById('chat-toggle');
        
        if (this.isOpen) {
            window.style.display = 'flex';
            toggle.style.display = 'none';
        } else {
            window.style.display = 'none';
            toggle.style.display = 'flex';
        }
    }

    addWelcomeMessage() {
        this.addMessage('ai', 'Hey! Give me feedback on this page and I\'ll update it live. 🚀');
    }

    addMessage(type, text) {
        const messagesContainer = document.getElementById('chat-messages');
        const messageEl = document.createElement('div');
        messageEl.className = `chat-message chat-message-${type}`;
        messageEl.textContent = text;
        messagesContainer.appendChild(messageEl);
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
        this.messages.push({ type, text });
    }

    async sendMessage() {
        const input = document.getElementById('chat-input');
        const message = input.value.trim();
        if (!message) return;

        this.addMessage('user', message);
        input.value = '';

        // Show typing indicator
        this.addMessage('ai', 'Updating...');

        try {
            // Send to OpenClaw gateway
            const response = await fetch('http://localhost:18789/api/chat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer 16ed6cbc6c3af9fad36115b86c4beba9da1f107a8612b1a7'
                },
                body: JSON.stringify({
                    message: `Website feedback for heyitsmejosh.com/automation: ${message}`,
                    session: 'main'
                })
            });

            const data = await response.json();
            
            // Remove typing indicator
            const messages = document.querySelectorAll('.chat-message');
            messages[messages.length - 1].remove();
            
            // Add response
            this.addMessage('ai', data.response || 'Got it! Updating the page...');
            
            // Reload page after 2 seconds to show changes
            setTimeout(() => location.reload(), 2000);
            
        } catch (error) {
            console.error('Chat error:', error);
            const messages = document.querySelectorAll('.chat-message');
            messages[messages.length - 1].textContent = 'Error connecting. Please use iMessage instead.';
        }
    }
}

// Inject CSS
const style = document.createElement('style');
style.textContent = `
    .chat-widget {
        position: fixed;
        bottom: 24px;
        right: 24px;
        z-index: 9999;
        font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
    }

    .chat-toggle {
        width: 64px;
        height: 64px;
        border-radius: 50%;
        background: #0071E3;
        border: none;
        color: white;
        cursor: pointer;
        box-shadow: 0 8px 24px rgba(0, 113, 227, 0.3);
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.3s ease;
    }

    .chat-toggle:hover {
        transform: scale(1.05);
        box-shadow: 0 12px 32px rgba(0, 113, 227, 0.4);
    }

    .chat-window {
        width: 380px;
        height: 520px;
        background: rgba(255, 255, 255, 0.95);
        backdrop-filter: blur(20px);
        -webkit-backdrop-filter: blur(20px);
        border-radius: 16px;
        box-shadow: 0 16px 48px rgba(0, 0, 0, 0.15);
        display: flex;
        flex-direction: column;
        overflow: hidden;
        border: 1px solid rgba(0, 0, 0, 0.08);
    }

    .chat-header {
        padding: 20px;
        background: #0071E3;
        color: white;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .chat-title {
        font-size: 17px;
        font-weight: 600;
    }

    .chat-subtitle {
        font-size: 13px;
        opacity: 0.9;
        margin-top: 2px;
    }

    .chat-close {
        width: 32px;
        height: 32px;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.2);
        border: none;
        color: white;
        font-size: 24px;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        line-height: 1;
    }

    .chat-close:hover {
        background: rgba(255, 255, 255, 0.3);
    }

    .chat-messages {
        flex: 1;
        padding: 20px;
        overflow-y: auto;
        display: flex;
        flex-direction: column;
        gap: 12px;
    }

    .chat-message {
        padding: 12px 16px;
        border-radius: 12px;
        max-width: 80%;
        font-size: 15px;
        line-height: 1.4;
    }

    .chat-message-user {
        background: #0071E3;
        color: white;
        align-self: flex-end;
        border-bottom-right-radius: 4px;
    }

    .chat-message-ai {
        background: #F5F5F7;
        color: #1D1D1F;
        align-self: flex-start;
        border-bottom-left-radius: 4px;
    }

    .chat-input-container {
        padding: 16px;
        background: white;
        border-top: 1px solid rgba(0, 0, 0, 0.08);
        display: flex;
        gap: 8px;
    }

    #chat-input {
        flex: 1;
        padding: 12px 16px;
        border: 1px solid rgba(0, 0, 0, 0.1);
        border-radius: 12px;
        font-size: 15px;
        outline: none;
        font-family: inherit;
    }

    #chat-input:focus {
        border-color: #0071E3;
    }

    #chat-send {
        padding: 12px 20px;
        background: #0071E3;
        color: white;
        border: none;
        border-radius: 12px;
        font-size: 15px;
        font-weight: 500;
        cursor: pointer;
        font-family: inherit;
    }

    #chat-send:hover {
        background: #0051c3;
    }

    @media (max-width: 480px) {
        .chat-window {
            width: calc(100vw - 32px);
            height: calc(100vh - 100px);
            right: 16px;
            bottom: 16px;
        }
    }
`;
document.head.appendChild(style);

// Initialize chat widget on page load
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => new ChatWidget());
} else {
    new ChatWidget();
}
