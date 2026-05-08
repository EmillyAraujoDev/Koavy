package com.example.demoApi.controller;

import com.example.demoApi.model.Relatorio;
import com.example.demoApi.repository.RelatorioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/relatorios")
public class RelatorioController {

    @Autowired
    private RelatorioRepository repository;

    // CREATE
    @PostMapping
    public Relatorio criar(@RequestBody Relatorio relatorio) {
        return repository.save(relatorio);
    }

    // READ (Todos)
    @GetMapping
    public List<Relatorio> listarTodos() {
        return repository.findAll();
    }

    // READ (Por Usuário)
    @GetMapping("/usuario/{usuarioId}")
    public List<Relatorio> listarPorUsuario(@PathVariable Long usuarioId) {
        return repository.findByUsuarioIdOrderByDataRefDesc(usuarioId);
    }

    // UPDATE
    @PutMapping("/{id}")
    public ResponseEntity<Relatorio> atualizar(@PathVariable Long id, @RequestBody Relatorio dados) {
        return repository.findById(id).map(relatorio -> {
            relatorio.setDataRef(dados.getDataRef());
            relatorio.setMediaBpm(dados.getMediaBpm());
            relatorio.setBpmMax(dados.getBpmMax());
            relatorio.setBpmMin(dados.getBpmMin());
            relatorio.setMediaSaturacao(dados.getMediaSaturacao());
            relatorio.setObs(dados.getObs());
            return ResponseEntity.ok(repository.save(relatorio));
        }).orElse(ResponseEntity.notFound().build());
    }

    // DELETE
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        if (repository.existsById(id)) {
            repository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}