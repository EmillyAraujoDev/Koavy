package com.example.demoApi.controller;

import java.util.List;
import java.util.Optional;

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

import com.example.demoApi.model.Usuario;
import com.example.demoApi.repository.UsuarioRepository;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api/usuarios")
public class UsuarioController {

    @Autowired
    private UsuarioRepository repository;

    // CREATE (POST)
    @PostMapping("/cadastro")
    public ResponseEntity<Usuario> cadastrar(@RequestBody Usuario usuario) {
        Usuario salvo = repository.save(usuario);
        return ResponseEntity.ok(salvo);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Usuario login) {

        Optional<Usuario> userOpt = repository.findByEmail(login.getEmail());

        if (userOpt.isEmpty()) {
            return ResponseEntity.status(401).body("Usuário não encontrado");
        }

        Usuario user = userOpt.get();

        if (!user.getSenha().equals(login.getSenha())) {
            return ResponseEntity.status(401).body("Senha incorreta");
        }

        return ResponseEntity.ok(user);
    }

    // READ ALL (GET)
    @GetMapping
    public List<Usuario> listarTodos() {
        return repository.findAll();
    }

    // READ BY ID (GET) - Protegido por Regex
    @GetMapping("/{id:[0-9]+}")
    public ResponseEntity<Usuario> buscarPorId(@PathVariable Long id) {
        return repository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // UPDATE (PUT) - Protegido por Regex
    @PutMapping("/{id:[0-9]+}")
    public ResponseEntity<Usuario> atualizar(@PathVariable Long id, @RequestBody Usuario dados) {
        return repository.findById(id).map(usuario -> {
            usuario.setPerfilId(dados.getPerfilId());
            usuario.setNome(dados.getNome());
            usuario.setEmail(dados.getEmail());
            usuario.setSenha(dados.getSenha());
            usuario.setIdade(dados.getIdade());
            usuario.setDataNascimento(dados.getDataNascimento());
            usuario.setSexo(dados.getSexo());
            usuario.setTelefone(dados.getTelefone());
            usuario.setTipoSanguineo(dados.getTipoSanguineo());
            usuario.setPeso(dados.getPeso());
            usuario.setAltura(dados.getAltura());
            usuario.setMarcapasso(dados.getMarcapasso());
            usuario.setObsMed(dados.getObsMed());
            usuario.setCep(dados.getCep());
            usuario.setAtivo(dados.getAtivo());

            Usuario atualizado = repository.save(usuario);
            return ResponseEntity.ok(atualizado);
        }).orElse(ResponseEntity.notFound().build());
    }

    // DELETE (DELETE) - Protegido por Regex
    @DeleteMapping("/{id:[0-9]+}")
    public ResponseEntity<Void> deletar(@PathVariable Long id) {
        if (repository.existsById(id)) {
            repository.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}