import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/data_models.dart';

class DatabaseService {
  static const String _fornecedoresKey = 'fornecedores';
  static const String _categoriasKey = 'categorias';
  static const String _produtosKey = 'produtos';
  static const String _produtosVendaKey = 'produtos_venda';
  static const String _mesasKey = 'mesas';
  static const String _vendasKey = 'vendas';
  static const String _pedidosKey = 'pedidos';
  static const String _pedidoItensKey = 'pedido_itens';
  static const String _receitasKey = 'receitas';
  static const String _receitaIngredientesKey = 'receita_ingredientes';
  static const String _producoesKey = 'producoes';
  static const String _producaoIngredientesKey = 'producao_ingredientes';
  static const String _estoqueKey = 'estoque';
  static const String _entradasEstoqueKey = 'entradas_estoque';
  static const String _ajustesEstoqueKey = 'ajustes_estoque';
  static const String _consumoInternoKey = 'consumo_interno';

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Carrega dados iniciais se necessário
  Future<void> initializeData() async {
    final prefs = await SharedPreferences.getInstance();

    // Verifica se já existem dados
    if (!prefs.containsKey(_mesasKey)) {
      // Cria algumas mesas de exemplo
      List<Mesa> mesas = List.generate(
        10,
        (index) => Mesa(
          numero_mesa: index + 1,
          quantidade_lugares: (index % 3 + 2),
        ),
      );
      await saveMesas(mesas);
    }

    // Criar categorias se não existirem
    if (!prefs.containsKey(_categoriasKey)) {
      List<Categoria> categorias = [
        Categoria(nome: 'Bebidas', descricao: 'Bebidas em geral'),
        Categoria(nome: 'Comidas', descricao: 'Alimentos em geral'),
        Categoria(nome: 'Outros', descricao: 'Produtos diversos'),
      ];
      await saveCategorias(categorias);
    }

    // Cria produtos de exemplo se não existirem
    if (!prefs.containsKey(_produtosKey)) {
      final categorias = await getCategorias();
      int idBebidas =
          categorias.isNotEmpty ? categorias[0].id_categoria ?? 1 : 1;
      int idComidas =
          categorias.length > 1 ? categorias[1].id_categoria ?? 2 : 2;

      List<Produto> produtos = [
        Produto(
          nome: 'Chopp',
          unidade_base: 'ml',
          tipo_produto: 'compra',
          controla_estoque: true,
          id_categoria: idBebidas,
        ),
        Produto(
          nome: 'Caipirinha',
          unidade_base: 'unidade',
          tipo_produto: 'producao',
          controla_estoque: true,
          id_categoria: idBebidas,
        ),
        Produto(
          nome: 'Batata Frita',
          unidade_base: 'porção',
          tipo_produto: 'producao',
          controla_estoque: true,
          id_categoria: idComidas,
        ),
        Produto(
          nome: 'Isca de Frango',
          unidade_base: 'porção',
          tipo_produto: 'producao',
          controla_estoque: true,
          id_categoria: idComidas,
        ),
        Produto(
          nome: 'Refrigerante Lata',
          unidade_base: 'unidade',
          tipo_produto: 'compra',
          controla_estoque: true,
          id_categoria: idBebidas,
        ),
      ];
      await saveProdutos(produtos);

      // Criar produtos para venda baseados nos produtos
      List<ProdutoVenda> produtosVenda = [];
      for (var i = 0; i < produtos.length; i++) {
        produtosVenda.add(ProdutoVenda(
          id_produto: i + 1, // Simulate ID
          descricao_venda: '${produtos[i].nome} (Padrão)',
          quantidade_base: 1,
          preco_venda: 10.0 * (i + 1), // Sample pricing
        ));
      }
      await saveProdutosVenda(produtosVenda);

      // Criar estoque inicial
      List<Estoque> estoqueItens = [];
      for (var i = 0; i < produtos.length; i++) {
        estoqueItens.add(Estoque(
          id_produto: i + 1,
          quantidade_disponivel: 50.0,
          data_atualizacao: DateTime.now(),
        ));
      }
      await saveEstoque(estoqueItens);
    }

    // Cria fornecedores de exemplo
    if (!prefs.containsKey(_fornecedoresKey)) {
      List<Fornecedor> fornecedores = [
        Fornecedor(
          nome: 'Distribuidora de Bebidas ABC',
          telefone: '(11) 99999-8888',
          email: 'contato@distribuidoraabc.com',
          contato: 'João Silva',
          detalhes: 'Entrega toda segunda-feira',
        ),
        Fornecedor(
          nome: 'Alimentos Frescos Ltda',
          telefone: '(11) 97777-6666',
          email: 'vendas@alimentosfrescos.com',
          contato: 'Maria Oliveira',
          detalhes: 'Fornecedor de alimentos frescos',
        ),
      ];
      await saveFornecedores(fornecedores);
    }

    // Cria receitas de exemplo
    if (!prefs.containsKey(_receitasKey)) {
      final categorias = await getCategorias();
      int idBebidas =
          categorias.isNotEmpty ? categorias[0].id_categoria ?? 1 : 1;
      int idComidas =
          categorias.length > 1 ? categorias[1].id_categoria ?? 2 : 2;

      List<Receita> receitas = [
        Receita(
          nome: 'Caipirinha Tradicional',
          tipo_receita: 'cocktail',
          preco_venda: 18.0,
          tempo_preparo_minutos: 5,
          id_categoria: idBebidas,
        ),
        Receita(
          nome: 'Porção de Batata Frita',
          tipo_receita: 'porcao',
          preco_venda: 25.0,
          tempo_preparo_minutos: 15,
          id_categoria: idComidas,
        ),
      ];
      await saveReceitas(receitas);

      // Adicionar ingredientes às receitas
      final produtos = await getProdutos();
      if (produtos.isNotEmpty && receitas.isNotEmpty) {
        List<ReceitaIngrediente> ingredientes = [
          ReceitaIngrediente(
            id_receita: 1,
            id_produto: produtos[0].id_produto ?? 1,
            quantidade_utilizada: 50.0,
          ),
          ReceitaIngrediente(
            id_receita: 2,
            id_produto: produtos[2].id_produto ?? 3,
            quantidade_utilizada: 300.0,
          ),
        ];
        await saveReceitaIngredientes(ingredientes);
      }
    }

    // Cria produções caseiras de exemplo
    if (!prefs.containsKey(_producoesKey)) {
      List<ProducaoCaseira> producoes = [
        ProducaoCaseira(
          nome: 'Cachaça de Abacaxi',
          quantidade_gerada: 1000.0,
          unidade_gerada: 'ml',
          tempo_preparo: 30,
          data_inicio_producao:
              DateTime.now().subtract(const Duration(days: 7)),
          data_fim_disponivel: DateTime.now().add(const Duration(days: 14)),
        ),
      ];
      await saveProducoes(producoes);

      // Adicionar ingredientes às produções
      final produtos = await getProdutos();
      if (produtos.isNotEmpty && producoes.isNotEmpty) {
        List<ProducaoIngrediente> ingredientes = [
          ProducaoIngrediente(
            id_producao: 1,
            id_produto: produtos[0].id_produto ?? 1,
            quantidade_utilizada: 1000.0,
          ),
          ProducaoIngrediente(
            id_producao: 1,
            id_produto: produtos[1].id_produto ?? 2,
            quantidade_utilizada: 2.0,
          ),
        ];
        await saveProducaoIngredientes(ingredientes);
      }
    }
  }

  // Métodos para Fornecedores
  Future<List<Fornecedor>> getFornecedores() async {
    final prefs = await SharedPreferences.getInstance();
    final fornecedoresJson = prefs.getStringList(_fornecedoresKey) ?? [];
    return fornecedoresJson
        .map((e) => Fornecedor.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> saveFornecedores(List<Fornecedor> fornecedores) async {
    final prefs = await SharedPreferences.getInstance();
    final fornecedoresJson =
        fornecedores.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_fornecedoresKey, fornecedoresJson);
  }

  Future<void> addFornecedor(Fornecedor fornecedor) async {
    final fornecedores = await getFornecedores();
    // Set next available ID if null
    if (fornecedor.id_fornecedor == null) {
      int nextId = 1;
      if (fornecedores.isNotEmpty) {
        nextId = fornecedores
                .map((f) => f.id_fornecedor ?? 0)
                .reduce((a, b) => a > b ? a : b) +
            1;
      }
      fornecedor = Fornecedor(
        id_fornecedor: nextId,
        nome: fornecedor.nome,
        telefone: fornecedor.telefone,
        email: fornecedor.email,
        contato: fornecedor.contato,
        detalhes: fornecedor.detalhes,
      );
    }
    fornecedores.add(fornecedor);
    await saveFornecedores(fornecedores);
  }

  Future<void> updateFornecedor(Fornecedor fornecedor) async {
    final fornecedores = await getFornecedores();
    final index = fornecedores
        .indexWhere((e) => e.id_fornecedor == fornecedor.id_fornecedor);
    if (index != -1) {
      fornecedores[index] = fornecedor;
      await saveFornecedores(fornecedores);
    }
  }

  Future<void> deleteFornecedor(int id_fornecedor) async {
    final fornecedores = await getFornecedores();
    fornecedores.removeWhere((e) => e.id_fornecedor == id_fornecedor);
    await saveFornecedores(fornecedores);
  }

  // Métodos para Categorias
  Future<List<Categoria>> getCategorias() async {
    final prefs = await SharedPreferences.getInstance();
    final categoriasJson = prefs.getStringList(_categoriasKey) ?? [];
    return categoriasJson
        .map((e) => Categoria.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> saveCategorias(List<Categoria> categorias) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriasJson =
        categorias.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_categoriasKey, categoriasJson);
  }

  // Métodos para Produtos
  Future<List<Produto>> getProdutos() async {
    final prefs = await SharedPreferences.getInstance();
    final produtosJson = prefs.getStringList(_produtosKey) ?? [];
    return produtosJson.map((e) => Produto.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveProdutos(List<Produto> produtos) async {
    final prefs = await SharedPreferences.getInstance();
    final produtosJson = produtos.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_produtosKey, produtosJson);
  }

  Future<void> addProduto(Produto produto) async {
    final produtos = await getProdutos();
    // Set next available ID if null
    if (produto.id_produto == null) {
      int nextId = 1;
      if (produtos.isNotEmpty) {
        nextId = produtos
                .map((p) => p.id_produto ?? 0)
                .reduce((a, b) => a > b ? a : b) +
            1;
      }
      produto = Produto(
        id_produto: nextId,
        nome: produto.nome,
        unidade_base: produto.unidade_base,
        tipo_produto: produto.tipo_produto,
        controla_estoque: produto.controla_estoque,
        id_categoria: produto.id_categoria,
      );
    }
    produtos.add(produto);
    await saveProdutos(produtos);
  }

  // Métodos para Produtos Venda
  Future<List<ProdutoVenda>> getProdutosVenda() async {
    final prefs = await SharedPreferences.getInstance();
    final produtosVendaJson = prefs.getStringList(_produtosVendaKey) ?? [];
    return produtosVendaJson
        .map((e) => ProdutoVenda.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> saveProdutosVenda(List<ProdutoVenda> produtosVenda) async {
    final prefs = await SharedPreferences.getInstance();
    final produtosVendaJson =
        produtosVenda.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_produtosVendaKey, produtosVendaJson);
  }

  // Métodos para Estoque
  Future<List<Estoque>> getEstoque() async {
    final prefs = await SharedPreferences.getInstance();
    final estoqueJson = prefs.getStringList(_estoqueKey) ?? [];
    return estoqueJson.map((e) => Estoque.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveEstoque(List<Estoque> estoque) async {
    final prefs = await SharedPreferences.getInstance();
    final estoqueJson = estoque.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_estoqueKey, estoqueJson);
  }

  Future<void> updateEstoqueProduto(
      int id_produto, double nova_quantidade) async {
    final estoque = await getEstoque();
    final index = estoque.indexWhere((e) => e.id_produto == id_produto);
    if (index != -1) {
      estoque[index] = Estoque(
        id_estoque: estoque[index].id_estoque,
        id_produto: id_produto,
        quantidade_disponivel: nova_quantidade,
        data_atualizacao: DateTime.now(),
      );
      await saveEstoque(estoque);

      // Registrar ajuste de estoque
      await addAjusteEstoque(AjusteEstoque(
        id_produto: id_produto,
        quantidade_anterior: estoque[index].quantidade_disponivel,
        quantidade_nova: nova_quantidade,
        data_ajuste: DateTime.now(),
        motivo: 'Ajuste manual de estoque',
      ));
    } else {
      // Produto não encontrado no estoque, adicionar
      estoque.add(Estoque(
        id_produto: id_produto,
        quantidade_disponivel: nova_quantidade,
        data_atualizacao: DateTime.now(),
      ));
      await saveEstoque(estoque);

      // Registrar entrada de estoque
      await addEntradaEstoque(EntradaEstoque(
        id_produto: id_produto,
        quantidade_entrada: nova_quantidade,
        data_entrada: DateTime.now(),
        observacao: 'Estoque inicial',
      ));
    }
  }

  // Métodos para Entradas de Estoque
  Future<List<EntradaEstoque>> getEntradasEstoque() async {
    final prefs = await SharedPreferences.getInstance();
    final entradasJson = prefs.getStringList(_entradasEstoqueKey) ?? [];
    return entradasJson
        .map((e) => EntradaEstoque.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> saveEntradasEstoque(List<EntradaEstoque> entradas) async {
    final prefs = await SharedPreferences.getInstance();
    final entradasJson = entradas.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_entradasEstoqueKey, entradasJson);
  }

  Future<void> addEntradaEstoque(EntradaEstoque entrada) async {
    final entradas = await getEntradasEstoque();
    // Set next available ID if null
    if (entrada.id_entrada == null) {
      int nextId = 1;
      if (entradas.isNotEmpty) {
        nextId = entradas
                .map((e) => e.id_entrada ?? 0)
                .reduce((a, b) => a > b ? a : b) +
            1;
      }
      entrada = EntradaEstoque(
        id_entrada: nextId,
        id_produto: entrada.id_produto,
        quantidade_entrada: entrada.quantidade_entrada,
        data_entrada: entrada.data_entrada,
        observacao: entrada.observacao,
      );
    }
    entradas.add(entrada);
    await saveEntradasEstoque(entradas);

    // Update estoque
    final estoque = await getEstoque();
    final index = estoque.indexWhere((e) => e.id_produto == entrada.id_produto);
    if (index != -1) {
      estoque[index] = Estoque(
        id_estoque: estoque[index].id_estoque,
        id_produto: entrada.id_produto,
        quantidade_disponivel:
            estoque[index].quantidade_disponivel + entrada.quantidade_entrada,
        data_atualizacao: DateTime.now(),
      );
    } else {
      estoque.add(Estoque(
        id_produto: entrada.id_produto,
        quantidade_disponivel: entrada.quantidade_entrada,
        data_atualizacao: DateTime.now(),
      ));
    }
    await saveEstoque(estoque);
  }

  // Métodos para Ajustes de Estoque
  Future<List<AjusteEstoque>> getAjustesEstoque() async {
    final prefs = await SharedPreferences.getInstance();
    final ajustesJson = prefs.getStringList(_ajustesEstoqueKey) ?? [];
    return ajustesJson
        .map((e) => AjusteEstoque.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> saveAjustesEstoque(List<AjusteEstoque> ajustes) async {
    final prefs = await SharedPreferences.getInstance();
    final ajustesJson = ajustes.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_ajustesEstoqueKey, ajustesJson);
  }

  Future<void> addAjusteEstoque(AjusteEstoque ajuste) async {
    final ajustes = await getAjustesEstoque();
    // Set next available ID if null
    if (ajuste.id_ajuste == null) {
      int nextId = 1;
      if (ajustes.isNotEmpty) {
        nextId = ajustes
                .map((e) => e.id_ajuste ?? 0)
                .reduce((a, b) => a > b ? a : b) +
            1;
      }
      ajuste = AjusteEstoque(
        id_ajuste: nextId,
        id_produto: ajuste.id_produto,
        quantidade_anterior: ajuste.quantidade_anterior,
        quantidade_nova: ajuste.quantidade_nova,
        data_ajuste: ajuste.data_ajuste,
        motivo: ajuste.motivo,
      );
    }
    ajustes.add(ajuste);
    await saveAjustesEstoque(ajustes);

    // Update estoque directly
    final estoque = await getEstoque();
    final index = estoque.indexWhere((e) => e.id_produto == ajuste.id_produto);
    if (index != -1) {
      estoque[index] = Estoque(
        id_estoque: estoque[index].id_estoque,
        id_produto: ajuste.id_produto,
        quantidade_disponivel: ajuste.quantidade_nova,
        data_atualizacao: DateTime.now(),
      );
      await saveEstoque(estoque);
    }
  }

  // Métodos para Mesas
  Future<List<Mesa>> getMesas() async {
    final prefs = await SharedPreferences.getInstance();
    final mesasJson = prefs.getStringList(_mesasKey) ?? [];
    return mesasJson.map((e) => Mesa.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveMesas(List<Mesa> mesas) async {
    final prefs = await SharedPreferences.getInstance();
    final mesasJson = mesas.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_mesasKey, mesasJson);
  }

  Future<void> updateMesa(Mesa mesa) async {
    final mesas = await getMesas();
    final index = mesas.indexWhere((e) => e.id_mesa == mesa.id_mesa);
    if (index != -1) {
      mesas[index] = mesa;
      await saveMesas(mesas);
    }
  }

  // Métodos para Vendas
  Future<List<Venda>> getVendas() async {
    final prefs = await SharedPreferences.getInstance();
    final vendasJson = prefs.getStringList(_vendasKey) ?? [];
    return vendasJson.map((e) => Venda.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveVendas(List<Venda> vendas) async {
    final prefs = await SharedPreferences.getInstance();
    final vendasJson = vendas.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_vendasKey, vendasJson);
  }

  Future<void> addVenda(Venda venda) async {
    final vendas = await getVendas();
    // Set next available ID if null
    if (venda.id_venda == null) {
      int nextId = 1;
      if (vendas.isNotEmpty) {
        nextId =
            vendas.map((v) => v.id_venda ?? 0).reduce((a, b) => a > b ? a : b) +
                1;
      }
      venda = Venda(
        id_venda: nextId,
        id_mesa: venda.id_mesa,
        data_venda: venda.data_venda,
        status_aberta: venda.status_aberta,
        cancelada: venda.cancelada,
      );
    }
    vendas.add(venda);
    await saveVendas(vendas);

    // Atualiza status da mesa
    final mesas = await getMesas();
    final mesaIndex = mesas.indexWhere((t) => t.id_mesa == venda.id_mesa);
    if (mesaIndex != -1) {
      mesas[mesaIndex] = mesas[mesaIndex].copyWith(
        status_ocupada: true,
      );
      await saveMesas(mesas);
    }
  }

  Future<void> closeVenda(int id_venda) async {
    final vendas = await getVendas();
    final index = vendas.indexWhere((v) => v.id_venda == id_venda);
    if (index != -1) {
      vendas[index] = vendas[index].copyWith(
        status_aberta: false,
      );
      await saveVendas(vendas);

      // Atualiza estoque dos produtos
      final pedidos = await getPedidos();
      final pedidosVenda =
          pedidos.where((p) => p.id_venda == id_venda).toList();

      for (var pedido in pedidosVenda) {
        final itens = await getPedidoItensByPedido(pedido.id_pedido!);
        for (var item in itens) {
          if (item.tipo_item == 'produto') {
            await consumirEstoque(item.id_item, item.quantidade);
          }
        }
      }

      // Libera a mesa
      final id_mesa = vendas[index].id_mesa;
      final mesas = await getMesas();
      final mesaIndex = mesas.indexWhere((t) => t.id_mesa == id_mesa);
      if (mesaIndex != -1) {
        mesas[mesaIndex] = mesas[mesaIndex].copyWith(
          status_ocupada: false,
          nome_cliente: null,
        );
        await saveMesas(mesas);
      }
    }
  }

  Future<void> cancelVenda(int id_venda) async {
    final vendas = await getVendas();
    final index = vendas.indexWhere((v) => v.id_venda == id_venda);
    if (index != -1) {
      vendas[index] = vendas[index].copyWith(
        cancelada: true,
        status_aberta: false,
      );
      await saveVendas(vendas);

      // Libera a mesa
      final id_mesa = vendas[index].id_mesa;
      final mesas = await getMesas();
      final mesaIndex = mesas.indexWhere((t) => t.id_mesa == id_mesa);
      if (mesaIndex != -1) {
        mesas[mesaIndex] = mesas[mesaIndex].copyWith(
          status_ocupada: false,
          nome_cliente: null,
        );
        await saveMesas(mesas);
      }
    }
  }

  // Métodos para Pedidos
  Future<List<Pedido>> getPedidos() async {
    final prefs = await SharedPreferences.getInstance();
    final pedidosJson = prefs.getStringList(_pedidosKey) ?? [];
    return pedidosJson.map((e) => Pedido.fromJson(jsonDecode(e))).toList();
  }

  Future<void> savePedidos(List<Pedido> pedidos) async {
    final prefs = await SharedPreferences.getInstance();
    final pedidosJson = pedidos.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_pedidosKey, pedidosJson);
  }

  Future<void> addPedido(Pedido pedido) async {
    final pedidos = await getPedidos();
    // Set next available ID if null
    if (pedido.id_pedido == null) {
      int nextId = 1;
      if (pedidos.isNotEmpty) {
        nextId = pedidos
                .map((p) => p.id_pedido ?? 0)
                .reduce((a, b) => a > b ? a : b) +
            1;
      }
      pedido = Pedido(
        id_pedido: nextId,
        id_venda: pedido.id_venda,
        id_mesa: pedido.id_mesa,
        nome_funcionario: pedido.nome_funcionario,
        data_pedido: pedido.data_pedido,
        status_pedido: pedido.status_pedido,
      );
    }
    pedidos.add(pedido);
    await savePedidos(pedidos);
  }

  Future<void> updatePedidoStatus(int id_pedido, String status) async {
    final pedidos = await getPedidos();
    final index = pedidos.indexWhere((p) => p.id_pedido == id_pedido);
    if (index != -1) {
      pedidos[index] = pedidos[index].copyWith(
        status_pedido: status,
      );
      await savePedidos(pedidos);
    }
  }

  // Métodos para Itens de Pedido
  Future<List<PedidoItem>> getPedidoItens() async {
    final prefs = await SharedPreferences.getInstance();
    final itensJson = prefs.getStringList(_pedidoItensKey) ?? [];
    return itensJson.map((e) => PedidoItem.fromJson(jsonDecode(e))).toList();
  }

  Future<List<PedidoItem>> getPedidoItensByPedido(int id_pedido) async {
    final itens = await getPedidoItens();
    return itens.where((i) => i.id_pedido == id_pedido).toList();
  }

  Future<void> savePedidoItens(List<PedidoItem> itens) async {
    final prefs = await SharedPreferences.getInstance();
    final itensJson = itens.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_pedidoItensKey, itensJson);
  }

  Future<void> addPedidoItem(PedidoItem item) async {
    final itens = await getPedidoItens();
    // Set next available ID if null
    if (item.id_pedido_item == null) {
      int nextId = 1;
      if (itens.isNotEmpty) {
        nextId = itens
                .map((i) => i.id_pedido_item ?? 0)
                .reduce((a, b) => a > b ? a : b) +
            1;
      }
      item = PedidoItem(
        id_pedido_item: nextId,
        id_pedido: item.id_pedido,
        tipo_item: item.tipo_item,
        id_item: item.id_item,
        quantidade: item.quantidade,
        preco_unitario: item.preco_unitario,
        observacao: item.observacao,
      );
    }
    itens.add(item);
    await savePedidoItens(itens);
  }

  // Métodos para Receitas
  Future<List<Receita>> getReceitas() async {
    final prefs = await SharedPreferences.getInstance();
    final receitasJson = prefs.getStringList(_receitasKey) ?? [];
    return receitasJson.map((e) => Receita.fromJson(jsonDecode(e))).toList();
  }

  Future<void> saveReceitas(List<Receita> receitas) async {
    final prefs = await SharedPreferences.getInstance();
    final receitasJson = receitas.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_receitasKey, receitasJson);
  }

  Future<void> addReceita(Receita receita) async {
    final receitas = await getReceitas();
    // Set next available ID if null
    if (receita.id_receita == null) {
      int nextId = 1;
      if (receitas.isNotEmpty) {
        nextId = receitas
                .map((r) => r.id_receita ?? 0)
                .reduce((a, b) => a > b ? a : b) +
            1;
      }
      receita = Receita(
        id_receita: nextId,
        nome: receita.nome,
        tipo_receita: receita.tipo_receita,
        preco_venda: receita.preco_venda,
        tempo_preparo_minutos: receita.tempo_preparo_minutos,
        id_categoria: receita.id_categoria,
      );
    }
    receitas.add(receita);
    await saveReceitas(receitas);
  }

  // Métodos para Ingredientes de Receita
  Future<List<ReceitaIngrediente>> getReceitaIngredientes() async {
    final prefs = await SharedPreferences.getInstance();
    final ingredientesJson = prefs.getStringList(_receitaIngredientesKey) ?? [];
    return ingredientesJson
        .map((e) => ReceitaIngrediente.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<List<ReceitaIngrediente>> getReceitaIngredientesByReceita(
      int id_receita) async {
    final ingredientes = await getReceitaIngredientes();
    return ingredientes.where((i) => i.id_receita == id_receita).toList();
  }

  Future<void> saveReceitaIngredientes(
      List<ReceitaIngrediente> ingredientes) async {
    final prefs = await SharedPreferences.getInstance();
    final ingredientesJson =
        ingredientes.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_receitaIngredientesKey, ingredientesJson);
  }

  Future<void> addReceitaIngrediente(ReceitaIngrediente ingrediente) async {
    final ingredientes = await getReceitaIngredientes();
    // Set next available ID if null
    if (ingrediente.id == null) {
      int nextId = 1;
      if (ingredientes.isNotEmpty) {
        nextId =
            ingredientes.map((i) => i.id ?? 0).reduce((a, b) => a > b ? a : b) +
                1;
      }
      ingrediente = ReceitaIngrediente(
        id: nextId,
        id_receita: ingrediente.id_receita,
        id_produto: ingrediente.id_produto,
        quantidade_utilizada: ingrediente.quantidade_utilizada,
      );
    }
    ingredientes.add(ingrediente);
    await saveReceitaIngredientes(ingredientes);
  }

  // Métodos para Produções Caseiras
  Future<List<ProducaoCaseira>> getProducoes() async {
    final prefs = await SharedPreferences.getInstance();
    final producoesJson = prefs.getStringList(_producoesKey) ?? [];
    return producoesJson
        .map((e) => ProducaoCaseira.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> saveProducoes(List<ProducaoCaseira> producoes) async {
    final prefs = await SharedPreferences.getInstance();
    final producoesJson = producoes.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_producoesKey, producoesJson);
  }

  Future<void> addProducao(ProducaoCaseira producao) async {
    final producoes = await getProducoes();
    // Set next available ID if null
    if (producao.id_producao == null) {
      int nextId = 1;
      if (producoes.isNotEmpty) {
        nextId = producoes
                .map((p) => p.id_producao ?? 0)
                .reduce((a, b) => a > b ? a : b) +
            1;
      }
      producao = ProducaoCaseira(
        id_producao: nextId,
        nome: producao.nome,
        quantidade_gerada: producao.quantidade_gerada,
        unidade_gerada: producao.unidade_gerada,
        tempo_preparo: producao.tempo_preparo,
        data_inicio_producao: producao.data_inicio_producao,
        data_fim_disponivel: producao.data_fim_disponivel,
      );
    }
    producoes.add(producao);
    await saveProducoes(producoes);
  }

  // Métodos para Ingredientes de Produção
  Future<List<ProducaoIngrediente>> getProducaoIngredientes() async {
    final prefs = await SharedPreferences.getInstance();
    final ingredientesJson =
        prefs.getStringList(_producaoIngredientesKey) ?? [];
    return ingredientesJson
        .map((e) => ProducaoIngrediente.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<List<ProducaoIngrediente>> getProducaoIngredientesByProducao(
      int id_producao) async {
    final ingredientes = await getProducaoIngredientes();
    return ingredientes.where((i) => i.id_producao == id_producao).toList();
  }

  Future<void> saveProducaoIngredientes(
      List<ProducaoIngrediente> ingredientes) async {
    final prefs = await SharedPreferences.getInstance();
    final ingredientesJson =
        ingredientes.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_producaoIngredientesKey, ingredientesJson);
  }

  Future<void> addProducaoIngrediente(ProducaoIngrediente ingrediente) async {
    final ingredientes = await getProducaoIngredientes();
    // Set next available ID if null
    if (ingrediente.id == null) {
      int nextId = 1;
      if (ingredientes.isNotEmpty) {
        nextId =
            ingredientes.map((i) => i.id ?? 0).reduce((a, b) => a > b ? a : b) +
                1;
      }
      ingrediente = ProducaoIngrediente(
        id: nextId,
        id_producao: ingrediente.id_producao,
        id_produto: ingrediente.id_produto,
        quantidade_utilizada: ingrediente.quantidade_utilizada,
      );
    }
    ingredientes.add(ingrediente);
    await saveProducaoIngredientes(ingredientes);

    // Consumir estoque do ingrediente
    await consumirEstoque(
        ingrediente.id_produto, ingrediente.quantidade_utilizada);
  }

  // Consumo de estoque
  Future<void> consumirEstoque(int id_produto, double quantidade) async {
    final estoque = await getEstoque();
    final index = estoque.indexWhere((e) => e.id_produto == id_produto);
    if (index != -1) {
      final novaQuantidade = estoque[index].quantidade_disponivel - quantidade;
      if (novaQuantidade >= 0) {
        estoque[index] = Estoque(
          id_estoque: estoque[index].id_estoque,
          id_produto: id_produto,
          quantidade_disponivel: novaQuantidade,
          data_atualizacao: DateTime.now(),
        );
        await saveEstoque(estoque);

        // Registrar consumo
        await addConsumoInterno(ConsumoInterno(
          id_produto: id_produto,
          quantidade_consumida: quantidade,
          data_hora: DateTime.now(),
          motivo: 'Consumo para produção',
        ));
      }
    }
  }

  // Métodos para Consumo Interno
  Future<List<ConsumoInterno>> getConsumosInternos() async {
    final prefs = await SharedPreferences.getInstance();
    final consumosJson = prefs.getStringList(_consumoInternoKey) ?? [];
    return consumosJson
        .map((e) => ConsumoInterno.fromJson(jsonDecode(e)))
        .toList();
  }

  Future<void> saveConsumosInternos(List<ConsumoInterno> consumos) async {
    final prefs = await SharedPreferences.getInstance();
    final consumosJson = consumos.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_consumoInternoKey, consumosJson);
  }

  Future<void> addConsumoInterno(ConsumoInterno consumo) async {
    final consumos = await getConsumosInternos();
    // Set next available ID if null
    if (consumo.id_consumo == null) {
      int nextId = 1;
      if (consumos.isNotEmpty) {
        nextId = consumos
                .map((c) => c.id_consumo ?? 0)
                .reduce((a, b) => a > b ? a : b) +
            1;
      }
      consumo = ConsumoInterno(
        id_consumo: nextId,
        id_produto: consumo.id_produto,
        quantidade_consumida: consumo.quantidade_consumida,
        data_hora: consumo.data_hora,
        motivo: consumo.motivo,
      );
    }
    consumos.add(consumo);
    await saveConsumosInternos(consumos);
  }

  // Métodos para consultas específicas
  Future<Venda?> getVendaAtivaMesa(int id_mesa) async {
    final vendas = await getVendas();
    try {
      return vendas.firstWhere(
        (venda) => venda.id_mesa == id_mesa && venda.status_aberta,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<Venda>> getVendasAtivas() async {
    final vendas = await getVendas();
    return vendas.where((venda) => venda.status_aberta).toList();
  }

  Future<double> getVendasDiarias() async {
    final vendas = await getVendas();
    final today = DateTime.now();
    final vendasDiarias = vendas.where((venda) =>
        venda.data_venda.year == today.year &&
        venda.data_venda.month == today.month &&
        venda.data_venda.day == today.day &&
        !venda.status_aberta &&
        !venda.cancelada);

    double total = 0;
    for (var venda in vendasDiarias) {
      final pedidos = await getPedidos();
      final pedidosVenda =
          pedidos.where((p) => p.id_venda == venda.id_venda).toList();

      for (var pedido in pedidosVenda) {
        final itens = await getPedidoItensByPedido(pedido.id_pedido!);
        for (var item in itens) {
          total += item.quantidade * item.preco_unitario;
        }
      }
    }
    return total;
  }

  Future<List<Produto>> getProdutosEstoqueBaixo(int threshold) async {
    final produtos = await getProdutos();
    final estoque = await getEstoque();

    List<Produto> result = [];
    for (var produto in produtos) {
      if (produto.controla_estoque) {
        final itemEstoque = estoque.firstWhere(
          (e) => e.id_produto == produto.id_produto,
          orElse: () => Estoque(
            id_produto: produto.id_produto!,
            quantidade_disponivel: 0,
            data_atualizacao: DateTime.now(),
          ),
        );

        if (itemEstoque.quantidade_disponivel <= threshold) {
          result.add(produto);
        }
      }
    }

    return result;
  }
}
