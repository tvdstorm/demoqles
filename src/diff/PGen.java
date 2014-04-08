package diff;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.imp.pdb.facts.IConstructor;
import org.eclipse.imp.pdb.facts.ISourceLocation;
import org.eclipse.imp.pdb.facts.IString;
import org.eclipse.imp.pdb.facts.IValueFactory;
import org.rascalmpl.interpreter.Evaluator;
import org.rascalmpl.interpreter.IEvaluatorContext;
import org.rascalmpl.interpreter.IRascalMonitor;
import org.rascalmpl.interpreter.asserts.ImplementationError;
import org.rascalmpl.interpreter.control_exceptions.Throw;
import org.rascalmpl.interpreter.env.GlobalEnvironment;
import org.rascalmpl.interpreter.env.ModuleEnvironment;
import org.rascalmpl.interpreter.utils.JavaBridge;
import org.rascalmpl.interpreter.utils.RuntimeExceptionFactory;
import org.rascalmpl.parser.gtd.IGTD;
import org.rascalmpl.parser.gtd.exception.ParseError;
import org.rascalmpl.parser.gtd.result.action.VoidActionExecutor;
import org.rascalmpl.parser.gtd.result.out.DefaultNodeFlattener;
import org.rascalmpl.parser.uptr.UPTRNodeFactory;

public class PGen {
	private static final String PKG = "org.rascalmpl.parsewithgrammar";
	private Evaluator evaluator;
	private JavaBridge bridge;
	private final IValueFactory vf;
	private final Map<IConstructor, Class<IGTD<IConstructor, IConstructor, ISourceLocation>>> cache;
	private StringWriter errString;
	private StringWriter outString;

	public PGen(IValueFactory values) {
		this.cache = new HashMap<IConstructor, Class<IGTD<IConstructor, IConstructor, ISourceLocation>>>();
		this.vf = values;
	}

	private void init(IEvaluatorContext ctx) {
		if (this.evaluator == null) {
			GlobalEnvironment heap = new GlobalEnvironment();
			ModuleEnvironment root = new ModuleEnvironment("___SCREEN___", heap);
			errString = new StringWriter();
			outString = new StringWriter();
			PrintWriter err = new PrintWriter(errString);
			PrintWriter out = new PrintWriter(outString);
			this.evaluator = new Evaluator(vf, err, out, root, heap, ctx
					.getEvaluator().getClassLoaders(), ctx.getEvaluator()
					.getRascalResolver());
			this.evaluator.getConfiguration().setRascalJavaClassPathProperty(
					ctx.getConfiguration().getRascalJavaClassPathProperty());
			this.bridge = new JavaBridge(evaluator.getClassLoaders(), vf,
					ctx.getConfiguration());
			IRascalMonitor monitor = this.evaluator;
			monitor.startJob("Loading parser generator", 100, 139);
			try {
				evaluator.doImport(monitor,
						"lang::rascal::grammar::ParserGenerator");
			} catch (Throwable e) {
				throw new ImplementationError(
						"Exception while loading parser generator: "
								+ e.getMessage(), e);
			} finally {
				monitor.endJob(true);
			}
		}
	}

	public IConstructor parse(IConstructor grammar, IString sort, IString src,
			ISourceLocation loc, IEvaluatorContext ctx) {
		init(ctx);
		if (!cache.containsKey(grammar)) {
			cache.put(grammar, buildParser(grammar, loc));
		}
		try {
			IGTD<IConstructor, IConstructor, ISourceLocation> parser = cache
					.get(grammar).newInstance();
			return (IConstructor) parser
					.parse(sort.getValue(),
							loc.getURI(),
							src.getValue().toCharArray(),
							new VoidActionExecutor<IConstructor>(),
							new DefaultNodeFlattener<IConstructor, IConstructor, ISourceLocation>(),
							new UPTRNodeFactory());
		} catch (ParseError pe) {
			ISourceLocation errorLoc = vf
					.sourceLocation(pe.getLocation(), pe.getOffset(),
							pe.getLength(), pe.getBeginLine() + 1,
							pe.getEndLine() + 1, pe.getBeginColumn(),
							pe.getEndColumn());
			throw RuntimeExceptionFactory.parseError(errorLoc,
					evaluator.getCurrentAST(), evaluator.getStackTrace());
		} catch (InstantiationException e) {
			throw new ImplementationError("parser generator:" + e.getMessage(),
					e);
		} catch (IllegalAccessException e) {
			throw new ImplementationError("parser generator:" + e.getMessage(),
					e);
		}
	}

	private Class<IGTD<IConstructor, IConstructor, ISourceLocation>> buildParser(
			IConstructor grammar, ISourceLocation loc) {
		try {
			IString grammarName = makeGrammarName(grammar);
			IString classString = (IString) evaluator.call("newGenerate",
					vf.string(PKG), grammarName, grammar);
			debugOutput(classString.getValue(), "/tmp/parser.java");
			return bridge.compileJava(loc.getURI(),
					PKG + "." + grammarName.getValue(), classString.getValue());
		} catch (ClassCastException e) {
			throw new ImplementationError("parser generator:" + e.getMessage(),
					e);
		} catch (Throw e) {
			throw new ImplementationError("parser generator: " + e.getMessage()
					+ e.getTrace());
		}
	}

	private IString makeGrammarName(IConstructor grammar) {
		return vf.string("grammar_" + Math.abs(grammar.hashCode()));
	}

	void debugOutput(String classString, String file) {
		FileOutputStream s = null;
		try {
			s = new FileOutputStream(file);
			s.write(classString.getBytes());
			s.flush();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (s != null) {
				try {
					s.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
	}
}
