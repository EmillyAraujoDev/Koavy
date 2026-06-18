package com.example.demoApi.controller;

import com.example.demoApi.model.Relatorio;
import com.example.demoApi.repository.RelatorioRepository;
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
@RequestMapping("/api/relatorios")
public class RelatorioController {

    @Autowired
    private RelatorioRepository repository;

    @PostMapping
    public Relatorio criar(@RequestBody Relatorio relatorio) {
        return repository.save(relatorio);
    }

    @GetMapping
    public List<Relatorio> listarTodos() {
        return repository.findAll();
    }

    @GetMapping("/usuario/{usuarioId:[0-9]+}")
    public List<Relatorio> listarPorUsuario(@PathVariable Long usuarioId) {
        return repository.findByUsuarioIdOrderByDataGeracaoDesc(usuarioId);
    }

    @PutMapping("/{id:[0-9]+}")
    public ResponseEntity<Relatorio> atualizar(@PathVariable Long id, @RequestBody Relatorio dados) {
        return repository.findById(id).map(relatorio -> {
            relatorio.setTipo(dados.getTipo());
            relatorio.setDataInicio(dados.getDataInicio());
            relatorio.setDataFim(dados.getDataFim());
            relatorio.setMediaBpm(dados.getMediaBpm());
            relatorio.setBpmMax(dados.getBpmMax());
            relatorio.setBpmMin(dados.getBpmMin());
            relatorio.setTotalAlertas(dados.getTotalAlertas());
            relatorio.setObsIa(dados.getObsIa());
            relatorio.setFilePath(dados.getFilePath());
            return ResponseEntity.ok(repository.save(relatorio));
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
