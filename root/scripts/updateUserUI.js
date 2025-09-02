/**
 * Script para atualizar a interface conforme estado de login do usuário
 * Pode ser incluído em todas as páginas que requerem essa funcionalidade
 */

async function updateUserUI() {
    if (window.authService.isAuthenticated()) {
        try {
            let user = window.authService.getCurrentUser();
            if (!user) {
                // Tentar buscar perfil do usuário se não estiver carregado
                const profileResponse = await window.apiService.getProfile();
                user = profileResponse.user;
            }
            // Atualizar UI para usuário logado
            const userMenu = document.getElementById('user-menu');
            if (userMenu) {
                userMenu.innerHTML = `
                    <span>Olá, ${user.username}</span>
                    <button id="logoutBtn">Sair</button>
                `;
                document.getElementById('logoutBtn').addEventListener('click', () => {
                    window.authService.logout();
                    window.location.reload();
                });
            }
        } catch (error) {
            console.error('Erro ao obter perfil do usuário:', error);
        }
    }
}

// Executar ao carregar a página
document.addEventListener('DOMContentLoaded', () => {
    updateUserUI();
});
