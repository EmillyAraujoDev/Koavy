package com.example.demoApi.controller;

import com.example.demoApi.model.Emergencia;
import com.example.demoApi.repository.EmergenciaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/emergencias")
public class EmergenciaController {

    @Autowired
    private EmergenciaRepository repository;

    // CREATE
    @PostMapping
    public Emergencia criar(@RequestBody Emergencia emergencia) {
        return repository.save(emergencia);
    }

    // READ (Listar todas)
    @GetMapping
    public List<Emergencia> listarTodas() {
        return repository.findAll();
    }

    // READ (Por ID)
    @GetMapping("/{id:[0-9]+}")
    public ResponseEntity<Emergencia> buscarPorId(@PathVariable Long id) {
        return repository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // READ (Por Usuário)
    @GetMapping("/usuario/{usuarioId:[0-9]+}")
    public List<Emergencia> listarPorUsuario(@PathVariable Long usuarioId) {
        return repository.findByUsuarioId(usuarioId);
    }

    // UPDATE
    @PutMapping("/{id:[0-9]+}")
    public ResponseEntity<Emergencia> atualizar(@PathVariable Long id, @RequestBody Emergencia dados) {
        return repository.findById(id).map(emergencia -> {
            emergencia.setTipo(dados.getTipo());
            emergencia.setDescricao(dados.getDescricao());
            emergencia.setLocalReferencia(dados.getLocalReferencia());
            emergencia.setLatitude(dados.getLatitude());
            emergencia.setLongitude(dados.getLongitude());
            emergencia.setNotificacaoEnviada(dados.getNotificacaoEnviada());
            emergencia.setBatMomento(dados.getBatMomento());
            emergencia.setSatMomento(dados.getSatMomento());
            emergencia.setPreSistolicaMomento(dados.getPreSistolicaMomento());
            emergencia.setPreDiastolicaMomento(dados.getPreDiastolicaMomento());
            return ResponseEntity.ok(repository.save(emergencia));
        }).orElse(ResponseEntity.notFound().build());
    }

    // DELETE
    @DeleteMapping("/{id:[0-9]+}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        if (repository.existsById(id)) {
            repository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}