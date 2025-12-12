# Contributing to HM Wheat Farm

First off, thank you for considering contributing to HM Wheat Farm! It's people like you that make this resource better for everyone.

## 🤝 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the [existing issues](https://github.com/henrymops89/hm_wheatfarm/issues) to avoid duplicates.

**When reporting a bug, include:**
- A clear and descriptive title
- Steps to reproduce the issue
- Expected behavior vs actual behavior
- Your FiveM server version
- Framework (QBox/QBCore/ESX) and version
- ox_lib version
- Inventory system (ox_inventory/qs-inventory)
- Relevant console errors (F8)
- Screenshots (if applicable)

### Suggesting Features

Feature suggestions are welcome! Please:
- Check existing issues for similar suggestions
- Explain the feature and why it would be useful
- Provide examples of how it would work
- Consider if it fits the scope of the project

### Pull Requests

1. **Fork the repository**
   ```bash
   git clone https://github.com/henrymops89/hm_wheatfarm.git
   cd hm_wheatfarm
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```

3. **Make your changes**
   - Follow the existing code style
   - Comment your code where necessary
   - Test thoroughly on all supported frameworks

4. **Commit your changes**
   ```bash
   git commit -m 'Add amazing feature'
   ```
   
   **Commit Message Format:**
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `docs:` - Documentation changes
   - `style:` - Code style changes (formatting)
   - `refactor:` - Code refactoring
   - `perf:` - Performance improvements
   - `test:` - Adding tests
   - `chore:` - Maintenance tasks

5. **Push to your fork**
   ```bash
   git push origin feature/amazing-feature
   ```

6. **Open a Pull Request**
   - Provide a clear description of the changes
   - Reference any related issues
   - Include screenshots/videos if relevant

## 📝 Code Style Guidelines

### Lua Code Style

```lua
-- Use 4 spaces for indentation
-- Use camelCase for variables
local myVariable = "value"

-- Use PascalCase for functions
local function MyFunction()
    -- Code here
end

-- Comments should be clear and concise
-- Explain WHY, not WHAT (code should be self-explanatory)

-- Use meaningful variable names
local playerPed = PlayerPedId()  -- Good
local p = PlayerPedId()          -- Bad
```

### Configuration Style

```lua
-- Group related settings together
-- Use clear, descriptive keys
-- Include comments explaining non-obvious options

Config.MyFeature = {
    enabled = true,           -- Enable/disable feature
    value = 100,              -- Numeric value in [units]
    text = "Description",     -- Text description
}
```

### Framework Compatibility

When adding features that use framework functions:

```lua
-- ✅ CORRECT: Use helper functions
AddItem(source, 'wheat', 3)
Notify(source, 'Success!', 'success')

-- ❌ WRONG: Direct framework calls
if FrameworkName == "QBox" then
    -- Framework-specific code
end
```

## 🧪 Testing

**Before submitting a PR, test on:**
- [ ] QBox Framework
- [ ] QBCore Framework
- [ ] ESX Legacy
- [ ] Both inventory systems (ox_inventory, qs-inventory)
- [ ] Both tool modes (durability, permanent)
- [ ] All farming modes (manual, auto-farm)
- [ ] Performance (check resmon)

## 🌍 Adding Translations

To add a new language:

1. Create `locales/[language_code].lua`
2. Copy structure from `locales/en.lua`
3. Translate all strings
4. Add language to README.md
5. Test in-game

Example:
```lua
-- locales/it.lua (Italian)
local Translations = {
    blip_name = "Campo di Grano",
    textui_plow = "[E] Arare il Grano | [G] Auto-Farm",
    -- ... all other keys
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
```

## 📚 Documentation

- Update README.md if you add features
- Update CHANGELOG.md with your changes
- Add inline comments for complex code
- Update config.lua comments if needed

## 🔍 Code Review Process

1. **Automated Checks** - PR must pass (if we add CI/CD later)
2. **Code Review** - Maintainer reviews code quality
3. **Testing** - Maintainer tests on all frameworks
4. **Merge** - Once approved, PR is merged

## 💡 Tips for New Contributors

- **Start Small** - Fix typos, improve docs, add translations
- **Ask Questions** - Open an issue if unsure about something
- **Be Patient** - Code review takes time
- **Learn from Feedback** - Use review comments to improve

## 🚫 What NOT to Contribute

- Breaking changes without discussion
- Features outside project scope
- Unoptimized code (check resmon!)
- Framework-specific code without compatibility
- Code without proper testing
- Malicious code or backdoors

## 📞 Contact

- **Issues**: [GitHub Issues](https://github.com/henrymops89/hm_wheatfarm/issues)
- **Discussions**: [GitHub Discussions](https://github.com/henrymops89/hm_wheatfarm/discussions)

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing! 🙏**
