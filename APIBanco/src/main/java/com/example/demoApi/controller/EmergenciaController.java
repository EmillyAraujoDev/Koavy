package com.example.demoApi.controller;

import com.example.demoApi.model.Emergencia;
import com.example.demoApi.repository.EmergenciaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/emergencias")
public class EmergenciaController {

    @Autowired
    private EmergenciaRepository repository;

    @PostMapping
    public ResponseEntity<Emergencia> criar(@RequestBody Emergencia emergencia) {
        if (emergencia.getStatus() == null || emergencia.getStatus().isBlank()) {
            emergencia.setStatus("PENDENTE");
        }
        return ResponseEntity.ok(repository.save(emergencia));
    }

    @GetMapping
    public List<Emergencia> listarTodas() {
        return repository.findAll();
    }

    @GetMapping("/{id:[0-9]+}")
    public ResponseEntity<Emergencia> buscarPorId(@PathVariable Long id) {
        return repository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/usuario/{usuarioId:[0-9]+}")
    public List<Emergencia> listarPorUsuario(@PathVariable Long usuarioId) {
        return repository.findByUsuarioId(usuarioId);
    }

    @PutMapping("/{id:[0-9]+}")
    public ResponseEntity<Emergencia> atualizar(@PathVariable Long id, @RequestBody Emergencia dados) {
        return repository.findById(id).map(emergencia -> {
            emergencia.setAlertaId(dados.getAlertaId());
            emergencia.setLatitude(dados.getLatitude());
            emergencia.setLongitude(dados.getLongitude());
            emergencia.setStatus(dados.getStatus());
            emergencia.setDataResolucao(dados.getDataResolucao());
            return ResponseEntity.ok(repository.save(emergencia));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id:[0-9]+}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        if (repository.existsById(id)) {
            repository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}
