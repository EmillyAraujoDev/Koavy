package com.example.demoApi.controller;

import com.example.demoApi.model.TutorPaciente;
import com.example.demoApi.repository.TutorPacienteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
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
@RequestMapping("/api/vinculos")
public class TutorPacienteController {

    @Autowired
    private TutorPacienteRepository repository;

    @PostMapping
    public ResponseEntity<?> criarVinculo(@RequestBody TutorPaciente vinculo) {
        if (vinculo.getPacienteId() == null || vinculo.getTutorId() == null) {
            return ResponseEntity.badRequest().body("pacienteId e tutorId sao obrigatorios");
        }

        return repository.findByPacienteIdAndTutorId(vinculo.getPacienteId(), vinculo.getTutorId())
                .<ResponseEntity<?>>map(ResponseEntity::ok)
                .orElseGet(() -> {
                    try {
                        return ResponseEntity.ok(repository.save(vinculo));
                    } catch (DataIntegrityViolationException ex) {
                        return ResponseEntity.badRequest().body("Paciente ou tutor invalido para vinculo");
                    }
                });
    }

    @GetMapping
    public List<TutorPaciente> listarTodos() {
        return repository.findAll();
    }

    @GetMapping("/tutor/{tutorId:[0-9]+}")
    public List<TutorPaciente> listarPorTutor(@PathVariable Long tutorId) {
        return repository.findByTutorId(tutorId);
    }

    @GetMapping("/paciente/{pacienteId:[0-9]+}")
    public List<TutorPaciente> listarPorPaciente(@PathVariable Long pacienteId) {
        return repository.findByPacienteId(pacienteId);
    }

    @PutMapping("/{id:[0-9]+}")
    public ResponseEntity<TutorPaciente> atualizar(@PathVariable Long id, @RequestBody TutorPaciente dados) {
        return repository.findById(id).map(vinculo -> {
            vinculo.setPacienteId(dados.getPacienteId());
            vinculo.setTutorId(dados.getTutorId());
            vinculo.setPrincipal(dados.getPrincipal());
            return ResponseEntity.ok(repository.save(vinculo));
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
