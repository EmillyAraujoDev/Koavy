package com.example.demoApi.controller;

import com.example.demoApi.model.TutorPaciente;
import com.example.demoApi.repository.TutorPacienteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/vinculos")
public class TutorPacienteController {

    @Autowired
    private TutorPacienteRepository repository;

    // CREATE
    @PostMapping
    public ResponseEntity<TutorPaciente> criarVinculo(@RequestBody TutorPaciente vinculo) {
        return ResponseEntity.ok(repository.save(vinculo));
    }

    // READ ALL
    @GetMapping
    public List<TutorPaciente> listarTodos() {
        return repository.findAll();
    }

    // 🔥 AJUSTADO: agora usa nome (não ID)
    @GetMapping("/tutor/{nome}")
    public List<TutorPaciente> listarPorTutor(@PathVariable String nome) {
        return repository.findByNome(nome);
    }

    // UPDATE
    @PutMapping("/{id:[0-9]+}")
    public ResponseEntity<TutorPaciente> atualizar(
            @PathVariable Long id,
            @RequestBody TutorPaciente dados) {

        return repository.findById(id).map(vinculo -> {

            vinculo.setNome(dados.getNome());
            vinculo.setPacienteId(dados.getPacienteId());
            vinculo.setPrincipal(dados.getPrincipal());

            // ❌ REMOVIDO tutorId (não usar mais no fluxo atual)

            return ResponseEntity.ok(repository.save(vinculo));

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