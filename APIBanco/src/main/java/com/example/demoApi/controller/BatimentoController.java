package com.example.demoApi.controller;

import com.example.demoApi.model.Batimento;
import com.example.demoApi.repository.BatimentoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/batimentos")
public class BatimentoController {

    @Autowired
    private BatimentoRepository repository;

    // CREATE (POST) - Recebe dados da pulseira
    @PostMapping
    public ResponseEntity<Batimento> salvar(@RequestBody Batimento batimento) {
        return ResponseEntity.ok(repository.save(batimento));
    }

    // READ ALL (GET) - Lista todos os batimentos de todos os usuários
    @GetMapping
    public List<Batimento> listarTodos() {
        return repository.findAll();
    }

    // READ BY USUARIO (GET) - Histórico específico
    @GetMapping("/usuario/{usuarioId:[0-9]+}")
    public List<Batimento> listarPorUsuario(@PathVariable Long usuarioId) {
        return repository.findByUsuarioIdOrderByDataHoraDesc(usuarioId);
    }

    // UPDATE (PUT) - Para corrigir algum registro manualmente
    @PutMapping("/{id:[0-9]+}")
    public ResponseEntity<Batimento> atualizar(@PathVariable Long id, @RequestBody Batimento dados) {
        return repository.findById(id).map(batimento -> {
            batimento.setFrequenciaCard(dados.getFrequenciaCard());
            batimento.setSaturacao(dados.getSaturacao());
            batimento.setPressaoSistolica(dados.getPressaoSistolica());
            batimento.setPressaoDiastolica(dados.getPressaoDiastolica());
            batimento.setNivelEstresse(dados.getNivelEstresse());
            batimento.setMovimento(dados.getMovimento());
            return ResponseEntity.ok(repository.save(batimento));
        }).orElse(ResponseEntity.notFound().build());
    }

    // DELETE (DELETE) - Remove um registro específico
    @DeleteMapping("/{id:[0-9]+}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        if (repository.existsById(id)) {
            repository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}