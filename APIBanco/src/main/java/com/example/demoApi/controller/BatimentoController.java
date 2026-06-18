package com.example.demoApi.controller;

import com.example.demoApi.model.Batimento;
import com.example.demoApi.repository.BatimentoRepository;
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
@RequestMapping("/api/batimentos")
public class BatimentoController {

    @Autowired
    private BatimentoRepository repository;

    @PostMapping
    public ResponseEntity<Batimento> salvar(@RequestBody Batimento batimento) {
        if (batimento.getBpm() == null && batimento.getFrequenciaCard() != null) {
            batimento.setBpm(batimento.getFrequenciaCard());
        }
        if (batimento.getClassificacao() == null || batimento.getClassificacao().isBlank()) {
            batimento.setClassificacao("NORMAL");
        }
        if (batimento.getOrigem() == null || batimento.getOrigem().isBlank()) {
            batimento.setOrigem("MANUAL");
        }
        return ResponseEntity.ok(repository.save(batimento));
    }

    @GetMapping
    public List<Batimento> listarTodos() {
        return repository.findAll();
    }

    @GetMapping("/usuario/{usuarioId:[0-9]+}")
    public List<Batimento> listarPorUsuario(@PathVariable Long usuarioId) {
        return repository.findByUsuarioIdOrderByTimestampDesc(usuarioId);
    }

    @PutMapping("/{id:[0-9]+}")
    public ResponseEntity<Batimento> atualizar(@PathVariable Long id, @RequestBody Batimento dados) {
        return repository.findById(id).map(batimento -> {
            batimento.setBpm(dados.getBpm() != null ? dados.getBpm() : dados.getFrequenciaCard());
            batimento.setSaturacao(dados.getSaturacao());
            batimento.setPressaoSistolica(dados.getPressaoSistolica());
            batimento.setPressaoDiastolica(dados.getPressaoDiastolica());
            batimento.setTemperatura(dados.getTemperatura());
            batimento.setClassificacao(dados.getClassificacao());
            batimento.setOrigem(dados.getOrigem());
            return ResponseEntity.ok(repository.save(batimento));
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
