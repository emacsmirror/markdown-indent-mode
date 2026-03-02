.PHONY: test lint

test:
	emacs -Q --batch -l test/markdown-indent-mode-test.el -f ert-run-tests-batch-and-exit

lint:
	emacs -Q --batch --eval "(checkdoc-file \"markdown-indent-mode.el\")"
	emacs -Q --batch --eval "(checkdoc-file \"test/markdown-indent-mode-test.el\")"
