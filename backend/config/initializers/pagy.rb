require "pagy"

# Padrões da paginação da API.
Pagy::OPTIONS[:limit] = 20          # itens por página (default)
Pagy::OPTIONS[:max_limit] = 100     # teto do ?per_page
Pagy::OPTIONS[:limit_key] = "per_page"
