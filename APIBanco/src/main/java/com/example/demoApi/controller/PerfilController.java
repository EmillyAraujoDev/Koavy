package com.example.demoApi.controller;

import com.example.demoApi.model.Perfil;
import com.example.demoApi.repository.PerfilRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/perfis")
public class PerfilController {

    @Autowired
    private PerfilRepository repository;

    // CREATE
    @PostMapping
    public Perfil criar(@RequestBody Perfil perfil) {
        // Opcional: transformar em maiúsculo para manter padrão
        perfil.setNome(perfil.getNome().toUpperCase());
        return repository.save(perfil);
    }

    // READ (Todos)
    @GetMapping
    public List<Perfil> listarTodos() {
        return repository.findAll();
    }

    // READ (Por ID)
    @GetMapping("/{id}")
    public ResponseEntity<Perfil> buscarPorId(@PathVariable Long id) {
        return repository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // UPDATE
    @PutMapping("/{id}")
    public ResponseEntity<Perfil> atualizar(@PathVariable Long id, @RequestBody Perfil dados) {
        return repository.findById(id).map(perfil -> {
            perfil.setNome(dados.getNome().toUpperCase());
            return ResponseEntity.ok(repository.save(perfil));
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